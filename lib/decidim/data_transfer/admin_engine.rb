# frozen_string_literal: true

module Decidim
  module DataTransfer
    # This is the engine that runs on the public interface of `DataTransfer`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::DataTransfer::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :data_transfer do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "data_transfer#index"
      end

      def load_seed
        nil
      end
    end
  end
end
