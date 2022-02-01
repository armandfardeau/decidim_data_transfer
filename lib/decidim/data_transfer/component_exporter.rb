module Decidim
  module DataTransfer
    class ComponentExporter
      def self.for(component_id)
        new(component_id).export
      end

      def initialize(component_id)
        @component = Decidim::Component.find_by(id: component_id)
        @resources = resource_class_name.constantize
                                          .joins(:coauthorships)
                                          .where(component: @component)
      end

      def export_hash
        {
          component: exportable_attributes(@component,
                                           :settings,
                                           :name,
                                           :manifest_name
          ),
          resources: resources_hash,
          resource_type: resource_class_name
        }
      end

      def export
        dir = Rails.root.join("tmp/data_transfer")
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

        File.write("#{dir}/export_component_#{@component.id}.json", export_hash.to_json)
      end

      private

      def authors_hash_for_resource(resource)
        return unless resource.respond_to?(:authors)
        {
          authors: resource.authors.map do |author|
            exportable_attributes(author,
                                  :email,
                                  :name,
                                  :locale,
                                  :avatar,
                                  :delete_reason,
                                  :deleted_at,
                                  :admin,
                                  :managed,
                                  :roles,
                                  :email_on_notification,
                                  :nickname,
                                  :personal_url,
                                  :about,
                                  :type,
                                  :extended_data,
                                  :notification_types,
                                  :direct_message_types,
                                  :officialized_at,
                                  :officialized_as
            ).merge(avatar_url: author.avatar_url)
          end
        }
      end

      def attachments_hash_for_resource(resource)
        {
          attachments: resource.attachments.map do |attachment|
            exportable_attributes(attachment,
                                  :title,
                                  :description,
                                  :file,
                                  :content_type
            ).merge(file_url: attachment.file.url)
          end
        }
      end

      def resources_hash
        @resources.map do |resource|
          exportable_attributes(resource,
                                :title,
                                :body,
                                :state,
                                :answered_at,
                                :reference,
                                :address,
                                :latitude,
                                :longitude,
                                :published_at,
                                :coauthorships_count,
                                :position,
                                :cost,
                                :cost_report,
                                :execution_period,
                                :state_published_at,
          ).merge(authors_hash_for_resource(resource))
           .merge(attachments_hash_for_resource(resource))
        end
      end

      def exportable_attributes(element, *keys)
        element.attributes
               .deep_symbolize_keys
               .slice(*keys)
      end

      def resource_class_name
        @resource_class_name ||= "#{namespace}::#{model_class}"
      end

      def namespace
        (component_manifest.engine.to_s.split("::") - ["Engine"]).join("::")
      end

      def model_class
        component_manifest.name.capitalize.to_s.singularize
      end

      def component_manifest
        @component_manifest ||= @component.manifest
      end
    end
  end
end