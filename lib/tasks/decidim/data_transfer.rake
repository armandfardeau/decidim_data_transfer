namespace :decidim do
  namespace :data_transfer do
    desc "Export proposals component to a file"
    task :components_exporter, [:component_id] => :environment do |_task, args|
      Decidim::DataTransfer::ComponentExporter.for(args[:component_id])
    end

    desc "Import a file to a participatory space"
    task :components_importer, [:participatory_space_type, :participatory_space_id, :file_path, :user_id, :component_id, :fallback_class] => :environment do |_task, args|
      Decidim::DataTransfer::ComponentImporter.for(args[:participatory_space_type],
                                                   args[:participatory_space_id],
                                                   args[:file_path],
                                                   args[:user_id],
                                                   args[:component_id],
                                                   args[:fallback_class])
    end
  end
end
