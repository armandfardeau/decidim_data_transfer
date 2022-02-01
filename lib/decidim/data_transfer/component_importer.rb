module Decidim
  module DataTransfer
    class ComponentImporter
      def self.for(participatory_space_type, participatory_space_id, file_path, user_id, fallback_class)
        new(participatory_space_type, participatory_space_id, file_path, user_id, fallback_class).import
      end

      def initialize(participatory_space_type, participatory_space_id, file_path, user_id, fallback_class)
        @participatory_space_type = participatory_space_type
        @participatory_space = participatory_space_type.constantize
                                                       .find(participatory_space_id)
        @import_hash = import_hash(file_path)
        @current_user = Decidim::User.find(user_id)
        @fallback_class = fallback_class
      end

      def import
        ActiveRecord::Base.transaction do
          component = import_component
          import_resources(component)
        end
      end

      private

      def rewrite_hash(hash, old_key, new_key)
        hash.each_with_object({}) do |(key, value), new_hash|
          new_hash[key.gsub(old_key, new_key)] = value.is_a?(Hash) ? rewrite_hash(value, old_key, new_key) : value
        end
      end

      def rewrited_component_attributes(component_hash)
        return component_hash unless @fallback_class.present?

        old_key = component_hash["manifest_name"].singularize
        new_key = @fallback_class.split("::").last.downcase

        rewrite_hash(component_hash, old_key, new_key).merge("manifest_name" => new_key.pluralize)
      end

      def import_component
        component_hash = rewrited_component_attributes(@import_hash["component"])

        component_attributes = {
          participatory_space: @participatory_space,
          participatory_space_type: @participatory_space_type
        }.merge(component_hash.except("participatory_space_type", "participatory_space_id"))
         .deep_symbolize_keys

        component = Decidim::Component.new(component_attributes.except(:settings))
        component.settings = component_hash["settings"]["global"]
        component.default_step_settings = component_hash["settings"]["default_step"]
        component.save!
        component
      end

      def resource_class(resource_type)
        return resource_type.constantize unless @fallback_class.present?

        @fallback_class.constantize
      end

      def import_resources(component)
        @import_hash["resources"].each do |resource_hash|
          resource_attributes = resource_hash.merge(component: component).deep_symbolize_keys
          instance = resource_class(@import_hash["resource_type"]).new(resource_attributes.except(:authors, :attachments))

          resource_hash["authors"].each do |author|
            user = create_user(author)
            instance.add_coauthor(user)
          end

          instance.save!

          resource_hash["attachments"].each do |attachments|
            import_attachments(instance, attachments)
          end

          instance
        end
      end

      def existing_user(author)
        Decidim::User.find_by(
          organization: @participatory_space.organization,
          name: author["name"],
          email: author["email"].downcase,
        )
      end

      def invite_user!(author)
        author.invite!(
          @current_user,
          invitation_instructions: "invited_you_as_user"
        )
      end

      def create_user(author)
        return existing_user(author) if existing_user(author).present?

        user = Decidim::User.new(
          name: author["name"],
          email: author["email"].downcase,
          nickname: UserBaseEntity.nicknamize(author["name"], organization: @participatory_space.organization),
          organization: @participatory_space.organization,
        )

        invite_user!(user)

        user
      end

      def import_attachments(instance, attachments)
        file = File.open(Rails.root.join("tmp/data_transfer#{attachments["file_url"]}"))
        Decidim::Attachment.create!(
          title: attachments["title"],
          file: file,
          content_type: attachments["content_type"],
          file_size: file.size,
          attached_to: instance
        )
      end

      def import_hash(file_path)
        return unless File.exist?(file_path)

        JSON.parse(File.read(file_path))
      end
    end
  end
end