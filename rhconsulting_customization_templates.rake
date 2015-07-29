# Author: George Goh <george.goh@redhat.com>

class CustomizationTemplateImportExport
  class ParsedNonDialogYamlError < StandardError; end

  def import(filename)
    raise "Must supply filename" if filename.blank?
    customization_templates = YAML.load_file(filename)
    import_customization_templates(customization_templates)
  end

  def export(filename)
    raise "Must supply filename" if filename.blank?
    customization_templates_hash = export_customization_templates(CustomizationTemplate.where("system is not true").order(:id).all)
    File.write(filename, customization_templates_hash.to_yaml)
  end

private

  def import_customization_templates(customization_templates)
    begin
      customization_templates.each do |ct|
        customization_template = CustomizationTemplate.create(ct)
      end
    rescue
      raise ParsedNonDialogYamlError
    end
  end

  def export_customization_templates(customization_templates)
    # CustomizationTemplate objects have a relation with PxeImageType objects
    # through the pxe_image_type_id attribute.
    # As of CloudForms 3.1, PxeImageTypes are a fixed collection of objects
    # which cannot be modified in the application,
    # so we do not export them together with the Customization Templates.
    
    customization_templates.collect do |customization_template|
      included_attributes(customization_template.attributes, ["id", "created_at", "updated_at"])
    end.compact
  end

  def included_attributes(attributes, excluded_attributes)
    attributes.reject { |key, _| excluded_attributes.include?(key) }
  end

end

namespace :rhconsulting do
  namespace :customization_templates do

    desc 'Usage information'
    task :usage => [:environment] do
      puts 'Export - Usage: rake rhconsulting:customization_templates:export[/path/to/export]'
      puts 'Import - Usage: rake rhconsulting:customization_templates:import[/path/to/export]'
    end

    desc 'Import all customization templates from a YAML file'
    task :import, [:filename] => [:environment] do |_, arguments|
      CustomizationTemplateImportExport.new.import(arguments[:filename])
    end

    desc 'Exports all customization templates to a YAML file'
    task :export, [:filename] => [:environment] do |_, arguments|
      CustomizationTemplateImportExport.new.export(arguments[:filename])
    end

  end
end
