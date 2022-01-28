# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DataTransfer
    # This is the engine that runs on the public interface of data_transfer.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::DataTransfer

      routes do
        # Add engine routes here
        # resources :data_transfer
        # root to: "data_transfer#index"
      end

      initializer "decidim_data_transfer.assets" do |app|
        app.config.assets.precompile += %w[decidim_data_transfer_manifest.js decidim_data_transfer_manifest.css]
      end
    end
  end
end
