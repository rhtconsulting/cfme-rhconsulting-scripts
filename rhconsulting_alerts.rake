# Author: Brant Evans <bevans@redhat.com>

class MiqAlertsImportExport
  class ParsedNonDialogYamlError < StandardError; end

  def export(export_dir)
    raise "Must supply export dir" if export_dir.blank?

    # Export the Alerts
    export_alerts(export_dir)
  end

  def export_sets(export_dir)
    raise "Must supply export dir" if export_dir.blank?

    # Export the Alert Sets
    export_alert_sets(export_dir)
  end

  def import(import_name)
    raise "Must supply filename or directory" if import_name.blank?
    if File.file?(import_name)
      alerts = YAML.load_file(import_name)
      import_alerts(alerts)
    elsif File.directory?(import_name)
      Dir.glob("#{import_name}/*.yaml") do |fname|
        alerts = YAML.load_file(fname)
        import_alerts(alerts)
      end
    else
      raise "Argument is not a filename or directory"
    end
  end

  def import_sets(import_name)
    raise "Must supply filename or directory" if import_name.blank?
    if File.file?(import_name)
      alertsets = YAML.load_file(import_name)
      import_alert_sets(alertsets)
    elsif File.directory?(import_name)
      Dir.glob("#{import_name}/*.yaml") do |fname|
        alertsets = YAML.load_file(fname)
        import_alert_sets(alertsets)
      end
    else
      raise "Argument is not a filename or directory"
    end
  end

  private

  def export_alerts(export_dir)
    MiqAlert.order(:id).all.each do |a|
      # Replace characters in the description that are not allowed in filenames
      fname = a.description.gsub('/', '_')
      fname = fname.gsub('|', '_')

      File.write("#{export_dir}/#{fname}.yaml", a.export_to_yaml)
    end
  end

  def export_alert_sets(export_dir)
    MiqAlertSet.order(:id).all.each do |a|
      puts("Exporting Alert Set: #{a.description}")

      # Replace characters in the description that are not allowed in filenames
      fname = a.description.gsub('/', '_')
      fname = fname.gsub('|', '_')

      File.write("#{export_dir}/#{fname}.yaml", a.export_to_yaml)
    end
  end

  def import_alerts(alerts)
    MiqAlert.transaction do
      alerts.each do |alert|
        MiqAlert.import_from_hash(alert['MiqAlert'], {:preview => false})
      end
    end
  end

  def import_alert_sets(alertsets)
    MiqAlertSet.transaction do
      alertsets.each do |alertset|
        MiqAlertSet.import_from_hash(alertset['MiqAlertSet'], {:preview => false})
      end
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