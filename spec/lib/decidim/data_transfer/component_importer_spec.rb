require "spec_helper"

describe Decidim::DataTransfer::ComponentImporter do
  subject { described_class.new(participatory_space_type, participatory_space.id, file_path, admin.id, component&.id, fallback_class) }
  let(:component) { nil }
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, organization: organization) }
  let(:participatory_space) { create(:participatory_process, organization: organization) }
  let(:participatory_space_type) { participatory_space.class.name }
  let(:fallback_class) { "Decidim::Proposals::Proposal" }
  let(:file_path) { "./spec/export_component_dummy.json" }
  let(:import_hash) { JSON.parse(File.read(file_path)) }

  context "with no file" do
    let(:file_path) { "./spec/no_file.json" }

    it "raises an error" do
      expect { subject.import }.to raise_error("No file provided for #{file_path}")
    end
  end

  describe "initialize" do
    it "returns a participatory space" do
      expect(subject.instance_variable_get(:@participatory_space)).to eq(participatory_space)
    end

    it "returns a participatory space type" do
      expect(subject.instance_variable_get(:@participatory_space_type)).to eq(participatory_space_type)
    end

    it "returns a fallback class" do
      expect(subject.instance_variable_get(:@fallback_class)).to eq(fallback_class)
    end

    it "returns a import hash" do
      expect(subject.instance_variable_get(:@import_hash)).to eq(import_hash)
      expect(subject.instance_variable_get(:@import_hash)).to be_a(Hash)
    end
  end

  describe "Import" do
    context "when component id is provided" do
      let!(:component) { create(:proposal_component, participatory_space: participatory_space) }

      it "doesn't creates a component" do
        expect { subject.import }.to change { Decidim::Component.count }.by(0)
      end

      it "uses the component id" do
        expect { subject.import }.to change { Decidim::Proposals::Proposal.count }.by(3)
        expect(Decidim::Proposals::Proposal.last.component).to eq(component)
        expect(Decidim::Proposals::Proposal.last.title).to eq({
                                                                "ca" => "<script>alert('TITLE');</script> Amet eos tenetur. 207",
                                                                "en" => "<script>alert('TITLE');</script> Amet eos tenetur. 207",
                                                                "es" => "<script>alert('TITLE');</script> Amet eos tenetur. 207"
                                                              })
        expect(Decidim::Proposals::Proposal.last.authors.first.email).to eq("user9@example.org")
        expect { subject.import }.to change { Decidim::Attachment.count }.by(3)
      end
    end

    it "creates a component" do
      expect { subject.import }.to change { Decidim::Component.count }.by(1)
      expect(Decidim::Component.last.manifest_name).to eq("proposals")
      expect(Decidim::Component.last.settings).to include(:proposal_length)
      expect(Decidim::Component.last.default_step_settings).to include(:proposal_answering_enabled)
    end

    it "creates resources" do
      expect { subject.import }.to change { Decidim::Proposals::Proposal.count }.by(3)
      expect(Decidim::Proposals::Proposal.last.component).to eq(Decidim::Component.last)
      expect(Decidim::Proposals::Proposal.last.title).to eq({
                                                              "ca" => "<script>alert('TITLE');</script> Amet eos tenetur. 207",
                                                              "en" => "<script>alert('TITLE');</script> Amet eos tenetur. 207",
                                                              "es" => "<script>alert('TITLE');</script> Amet eos tenetur. 207"
                                                            })
      expect(Decidim::Proposals::Proposal.last.authors.first.email).to eq("user9@example.org")
      expect { subject.import }.to change { Decidim::Attachment.count }.by(3)
    end
  end
end