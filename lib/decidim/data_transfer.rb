# frozen_string_literal: true

require "decidim/data_transfer/admin"
require "decidim/data_transfer/engine"
require "decidim/data_transfer/admin_engine"

module Decidim
  # This namespace holds the logic of the `DataTransfer` component. This component
  # allows users to create data_transfer in a participatory space.
  module DataTransfer
    autoload :ComponentExporter, "decidim/data_transfer/component_exporter"
  end
end
