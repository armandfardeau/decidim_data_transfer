namespace :decidim do
  namespace :data_transfer do
    desc "Export proposals component to a file"
    task :components_exporter, [:component_id] => :environment do |_task, args|
      Decidim::DataTransfer::ComponentExporter.for(args[:component_id])
    end
  end
end
