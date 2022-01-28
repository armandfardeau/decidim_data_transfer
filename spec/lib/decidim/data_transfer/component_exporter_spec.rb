require "spec_helper"

describe Decidim::DataTransfer::ComponentExporter do
  subject { described_class.new(component.id) }
  let(:component) { create(:proposal_component) }
  let!(:ressources) { create_list(:proposal, 3, component: component) }
  let(:export_file) { Rails.root.join("tmp/data_transfer/export_component_#{component.id}.json") }

  describe "initialize" do
    it "returns a component" do
      expect(subject.instance_variable_get(:@component)).to eq(component)
    end

    it "returns ressources for components" do
      expect(subject.instance_variable_get(:@ressources)).to match_array(ressources)
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

    it "includes the ressource class type" do
      ressource_type = subject.export_hash[:ressource_type]

      expect(ressource_type).to eq("Decidim::Proposals::Proposal")
    end

    it "returns a hash with the ressources" do
      ressources = subject.export_hash[:ressources]

      expect(ressources).to be_a(Array)
      expect(ressources.first.keys).to match_array([
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
                                                  :authors
                                                ])
    end

    it "serializes the authors" do
      authors = subject.export_hash[:ressources].first[:authors]

      expect(authors).to be_a(Array)
      expect(authors.first.keys).to match_array([
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