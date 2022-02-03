require "spec_helper"

describe Decidim::DataTransfer::ComponentExporter do
  subject { described_class.new(component.id) }
  let(:component) { create(:proposal_component) }
  let!(:resources) { create_list(:proposal, 3, component: component) }
  let(:export_file) { Rails.root.join("tmp/data_transfer/export_component_#{component.id}.json") }
  let!(:attachments) do
    resources.map { |resource| create(:attachment, :with_image, attached_to: resource) }
  end

  describe "initialize" do
    it "returns a component" do
      expect(subject.instance_variable_get(:@component)).to eq(component)
    end

    it "returns resources for components" do
      expect(subject.instance_variable_get(:@resources)).to match_array(resources)
    end
  end

  describe "#export_hash" do
    it "returns a hash" do
      expect(subject.export_hash).to be_a(Hash)
    end

    it "returns a hash with the component" do
      component_hash = subject.export_hash[:component]

      expect(component_hash.keys).to match_array([
                                                   :settings,
                                                   :name,
                                                   :manifest_name
                                                 ])
    end

    it "includes the resource class type" do
      resource_type = subject.export_hash[:resource_type]

      expect(resource_type).to eq("Decidim::Proposals::Proposal")
    end

    it "returns a hash with the resources" do
      resources = subject.export_hash[:resources]

      expect(resources).to be_a(Array)
      expect(resources.first.keys).to match_array([
                                                    :title,
                                                    :body,
                                                    :state,
                                                    :answer,
                                                    :answered_at,
                                                    :cost,
                                                    :cost_report,
                                                    :execution_period,
                                                    :state_published_at,
                                                    :reference,
                                                    :address,
                                                    :latitude,
                                                    :longitude,
                                                    :published_at,
                                                    :coauthorships_count,
                                                    :position,
                                                    :authors,
                                                    :attachments
                                                  ])
    end

    it "serializes the authors" do
      authors = subject.export_hash[:resources].first[:authors]

      expect(authors).to be_a(Array)
      expect(authors.first.keys).to match_array([
                                                  :email,
                                                  :name,
                                                  :locale,
                                                  :avatar,
                                                  :avatar_url,
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
                                                ])
    end

    it "serializes the attachments" do
      attachments = subject.export_hash[:resources].first[:attachments]

      expect(attachments).to be_a(Array)
      expect(attachments.first.keys).to match_array([
                                                      :title,
                                                      :description,
                                                      :file,
                                                      :file_url,
                                                      :content_type
                                                    ])
    end
  end

  describe "#export" do
    it "create a file" do
      subject.export

      expect(File.exists?(export_file)).to be_truthy
    end
  end
end