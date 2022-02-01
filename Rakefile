# frozen_string_literal: true

require "decidim/dev/common_rake"

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app" do
  system("mkdir -p './spec/decidim_dummy_app/tmp/data_transfer'")
  system("cp -r ./spec/dummy_attachments/* ./spec/decidim_dummy_app/tmp/data_transfer")
end

desc "Generates a development app."
task development_app: "decidim:generate_external_development_app"
