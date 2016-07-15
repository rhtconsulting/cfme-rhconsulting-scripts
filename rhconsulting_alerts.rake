# Author: Brant Evans <bevans@redhat.com>

class MiqAlertsImportExport
  class ParsedNonDialogYamlError < StandardError; end

  def export(export_dir)
    raise "Must supply export dir" if export_dir.blank?

    # Export the Policies
    export_alerts(export_dir)
  end

  def import(import_dir)
    raise "Must supply import dir" if import_dir.blank?

    # Import the Policies
    import_alerts(import_dir)
  end

  private

  def export_policies(export_dir)
    MiqAlert.all.each do |a|
      puts("Exporting Alert: #{a.description}")

      # Replace characters in the description that are not allowed in filenames
      fname = a.description.gsub('/', '_')
      fname = fname.gsub('<', '_')
      fname = fname.gsub('>', '_')
      fname = fname.gsub('|', '_')

      File.write("#{export_dir}/#{fname}.yaml", p.export_to_yaml)
    end
  end

end


namespace :rhconsulting do
  namespace :miq_alerts do

    desc 'Usage information'
    task :usage => [:environment] do
      puts 'Export - Usage: rake \'rhconsulting:miq_alerts:export[/path/to/dir/with/alerts]\''
      puts 'Import - Usage: rake \'rhconsulting:miq_alerts:import[/path/to/dir/with/alerts]\''
    end

    desc 'Exports all alerts to individual YAML files'
    task :export, [:filedir] => [:environment] do |_, arguments|
      MiqAlertsImportExport.new.export(arguments[:filedir])
    end

    desc 'Imports all alerts from individual YAML files'
    task :import, [:filedir] => [:environment] do |_, arguments|
      MiqAlertsImportExport.new.import(arguments[:filedir])
    end

  end

  namespace :miq_alertsets do

    desc 'Usage information'
    task :usage => [:environment] do
      puts 'Export - Usage: rake \'rhconsulting:miq_alertsets:export[/path/to/dir/with/alertsets]\''
      puts 'Import - Usage: rake \'rhconsulting:miq_alertsets:import[/path/to/dir/with/alertsets]\''
    end

    desc 'Exports all alerts to individual YAML files'
    task :export, [:filedir] => [:environment] do |_, arguments|
      MiqAlertsImportExport.new.export_sets(arguments[:filedir])
    end

    desc 'Imports all alerts from individual YAML files'
    task :import, [:filedir] => [:environment] do |_, arguments|
      MiqAlertsImportExport.new.import_sets(arguments[:filedir])
    end

  end
end