# Author: Dustin Scott <dscott@redhat.com>
require_relative 'rhconsulting_illegal_chars'
require_relative 'rhconsulting_options'
require_relative 'rhconsulting_model_attributes'

class MiqSchedulesImportExport
  class ParsedNonDialogYamlError < StandardError; end

  def export(export_dir, options = {})
    raise "Must supply export dir" if export_dir.blank?

    # export the schedules
    export_schedules(export_dir, options)
  end

  def import(import_dir)
    raise "Must supply import dir" if import_dir.blank?

    # import the schedules
    import_schedules(import_dir)
  end

private

  # TODO: support only non-widget schedules for now; add widget schedules in the future
  WIDGET_SCHEDULES    = false
  ADDL_REJECTED_ATTRS = [
    'file_depot_id',
    'miq_schedule_id',
    'miq_search_id',
    'last_run_on',
    'task_id',
#    'zone_id'
  ].freeze
  
  # file depot params needed to ensure that we also create a file depot
  FILE_DEPOT_ATTRS = [ 'name', 'uri', 'type' ].freeze
  FILE_DEPOT_KEY   = 'file_depot'

  def parse_sched_action_options(model_object_attrs)
    sched_action_attrs   = model_object_attrs.fetch('sched_action')
    sched_action_options = sched_action_attrs.try(:fetch, :options, nil)
    return model_object_attrs unless sched_action_options

    parsed_sched_action_options = RhconsultingModelAttributes.parse_attributes(sched_action_options, ADDL_REJECTED_ATTRS)
    model_object_attrs['sched_action'][:options] = parsed_sched_action_options

    add_file_depot_attrs(model_object_attrs, sched_action_options[:file_depot_id])
  end

  def add_file_depot_attrs(model_object_attrs, file_depot_id)
    return model_object_attrs unless file_depot_id

    file_depot = FileDepot.find(file_depot_id)
    return model_object_attrs unless file_depot

    file_depot_attrs = file_depot.attributes.slice(FILE_DEPOT_ATTRS)
    model_object_attrs.merge!(file_depot_attrs)
  end

  def normalize_export_data(unnormalized_attrs)
    normalized_attrs = parse_sched_action_options(unnormalized_attrs)
    normalized_attrs = RhconsultingModelAttributes.parse_attributes(normalized_attrs, ADDL_REJECTED_ATTRS)
  end

  def export_schedules(export_dir, options)
    schedules = if WIDGET_SCHEDULES
                  MiqSchedule.all
                else
                  MiqSchedule.where('towhat != ?', 'MiqWidget')
                end

    schedules.each do |schedule|
      # set the filename and replace spaces and characters that are not allowed in filenames
      fname = MiqIllegalChars.replace("#{schedule.name}.yaml", options)

      normalized_attrs = normalize_export_data(schedule.attributes)
      File.write("#{export_dir}/#{fname}", normalized_attrs.to_yaml)
    end
  end

  def import_schedules(import_dir)
    # WORK IN PROGRESS:
    #   below left as an example for reference
    #
    # MiqWidget.transaction do
    #   Dir.glob("#{import_dir}/*yaml") do |filename|
    #     widgets = YAML.load_file(filename)
    #     widgets.each do |widget|
    #       MiqWidget.import_from_hash(widget['MiqWidget'], {:userid=>'admin', :overwrite=>true, :save=>true})
    #     end
    #   end
    # end
  end

end

namespace :rhconsulting do
  namespace :miq_schedules do

    desc 'Usage information'
    task :usage => [:environment] do
      puts 'Export - Usage: rake \'rhconsulting:miq_schedules:export[/path/to/dir/with/widgets]\''
      puts 'Import - Usage: rake \'rhconsulting:miq_schedules:import[/path/to/dir/with/widgets]\''
    end

    desc 'Exports all schedules (non-widget type) to individual YAML files'
    task :export, [:filedir] => [:environment] do |_, arguments|
      options = RhconsultingOptions.parse_options(arguments.extras)
      MiqSchedulesImportExport.new.export(arguments[:filedir], options)
    end

    desc 'Imports all schedules (non-widget type) from individual YAML files'
    task :import, [:filedir] => [:environment] do |_, arguments|
      MiqSchedulesImportExport.new.import(arguments[:filedir])
    end

  end
end
