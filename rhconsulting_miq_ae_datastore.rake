# Author: George Goh <george.goh@redhat.com>

class MiqAeDatastoreImportExport
  class ParsedNonDialogYamlError < StandardError; end

  def import(domain_name, import_dir)
    raise "Must supply domain name" if domain_name.blank?
    raise "Must supply import source directory" if import_dir.blank?
    importer = MiqAeYamlImportFs.new(domain_name, {'import_dir' => import_dir})
    importer.import
  end

  def export(domain_name, export_dir)
    raise "Must supply domain name" if domain_name.blank?
    raise "Must supply directory to export to" if export_dir.blank?
    exporter = MiqAeYamlExportFs.new(domain_name, {"export_dir" => export_dir, "overwrite" => true})
    exporter.export
  end
end

namespace :rhconsulting do
  namespace :miq_ae_datastore do

    desc 'Usage information'
    task :usage => [:environment] do
      puts 'Export - Usage: rake \'rhconsulting:miq_ae_datastore:export[domain_to_export, /path/to/export]\''
      puts 'Import - Usage: rake \'rhconsulting:miq_ae_datastore:import[domain_to_import, /path/to/import]\''
    end

    desc 'Import a specific AE Datastore domain from a directory'
    task :import, [:domain_name, :filename] => [:environment] do |_, arguments|
      MiqAeDatastoreImportExport.new.import(arguments[:domain_name], arguments[:filename])
    end

    desc 'Exports a specific AE Datastore domain to a directory'
    task :export, [:domain_name, :filename] => [:environment] do |_, arguments|
      MiqAeDatastoreImportExport.new.export(arguments[:domain_name], arguments[:filename])
    end

  end
end
