# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/data_transfer/version"

Gem::Specification.new do |s|
  s.version = Decidim::DataTransfer.version
  s.authors = ["Armand Fardeau"]
  s.email = ["fardeauarmand@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-data_transfer"
  s.required_ruby_version = ">= 2.5"

  s.name = "decidim-data_transfer"
  s.summary = "A decidim data_transfer module"
  s.description = "Data transfer for Decidim."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]
end
