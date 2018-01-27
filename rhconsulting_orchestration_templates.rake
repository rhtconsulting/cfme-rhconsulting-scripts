# Heavily based on a rails script written by Dustin Scott <dscott@redhat.com>
# Author: Brant Evans <bevans@redhat.com>
# Adopted from Provisioning Dialogs for Orchestration Templates by: Jeffrey Cutter <jcutter@redhat.com>
require_relative 'rhconsulting_illegal_chars'
require_relative 'rhconsulting_options'

class OrchestrationTemplateImportExport
  class ParsedNonDialogYamlError < StandardError; end

  def export(filedir, options = {})
    # Do some basic checks
    raise "Must supply export directory" if filedir.blank?
    raise "#{filedir} does not exist" if ! File.exist?(filedir)
    raise "#{filedir} is not a directory" if ! File.directory?(filedir)
    raise "#{filedir} is not a writable" if ! File.writable?(filedir)

    # Get the orchestration templates to export
    template_array = export_orchestration_templates

    # Save orchestration templates
    template_array.each do |template|
      # Set the filename and replace characters that are not allowed in filenames
      fname = MiqIllegalChars.replace("#{template[:name]}.yaml", options)
      File.write("#{filedir}/#{fname}", template.to_yaml)
    end
  end

  def import(import_name)
    raise "Must supply filename or directory" if import_name.blank?
    if File.file?(import_name)
      template = YAML.load_file(import_name)
      import_orchestration_templates(template)
    elsif File.directory?(import_name)
      Dir.glob("#{import_name}/*.yaml") do |fname|
        template = YAML.load_file(fname)
        import_orchestration_templates(template)
      end
    else
      raise "Argument is not a filename or directory"
    end
  end

  private

  def export_orchestration_templates
    template_array = []
    # Only export non-default templates
    OrchestrationTemplate.order(:id).where(:orderable => true).each do |template|
      template_hash = template.to_model_hash
      # Delete keys that are not needed. These will be recreated on import
      [ :class, :id, :created_at, :updated_at, :md5 ].each { |key| template_hash.delete(key) }
      # Put the resulting hash in our array to return
      template_array << template_hash
    end
    # Return the array
    template_array
  end

  def import_orchestration_templates(template)
    # Check if there is already a template with the same name that is being imported
    model_template = OrchestrationTemplate.where(:name => template[:name]).first

    # If an existing template was found update it otherwise create a new template
    if model_template.nil? then
      OrchestrationTemplate.create(template)
    else
      model_template.update(template)
    end
  end
end

namespace :rhconsulting do
  namespace :orchestration_templates do

    desc 'Usage information'
    task :usage => [:environment] do
      puts 'Export - Usage: rake rhconsulting:orchestration_templates:export[/path/to/dir/with/templates]'
      puts 'Import - Usage: rake rhconsulting:orchestration_templates:import[/path/to/dir/with/templates]'
    end

    desc 'Import all orchestration templates from individual YAML files'
    task :import, [:filedir] => [:environment] do |_, arguments|
      OrchestrationTemplateImportExport.new.import(arguments[:filedir])
    end

    desc 'Exports all orchestration templates to individual YAML files'
    task :export, [:filedir] => [:environment] do |_, arguments|
      options = RhconsultingOptions.parse_options(arguments.extras)
      OrchestrationTemplateImportExport.new.export(arguments[:filedir], options)
    end

  end
end

