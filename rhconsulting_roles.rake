class RoleImportExport
  class ParsedNonDialogYamlError < StandardError; end

  def import(filename)
    raise "Must supply filename" if filename.blank?
    roles = YAML.load_file(filename)
    import_roles(roles)
  end

  def export(filename)
    raise "Must supply filename" if filename.blank?
    roles_hash = export_roles(MiqUserRole.all)
    File.write(filename, roles_hash.to_yaml)
  end

private

  def import_roles(roles)
    begin
      roles.each do |r|
        r['miq_product_feature_ids'] = MiqProductFeature.all.collect do |f|
          f.id if r['feature_identifiers'] && r['feature_identifiers'].include?(f.identifier)
        end.compact
        role = MiqUserRole.find_or_create_by_name(r['name'])
        role.update_attributes!(r.reject { |k| k == 'feature_identifiers' })
      end
    rescue
      raise ParsedNonDialogYamlError
    end
  end

  def export_roles(roles)
    roles.collect do |role|
      next if role.read_only?
      included_attributes(role.attributes, ["created_at", "id", "updated_at"]).merge('feature_identifiers' => role.feature_identifiers)
    end.compact
  end

  def included_attributes(attributes, excluded_attributes)
    attributes.reject { |key, _| excluded_attributes.include?(key) }
  end

end

namespace :rhconsulting do
  namespace :roles do

    desc 'Usage information'
    task :usage => [:environment] do
      puts 'Export - Usage: rake rhconsulting:roles:export[/path/to/export]'
      puts 'Import - Usage: rake rhconsulting:roles:import[/path/to/export]'
    end

    desc 'Import all roles from a YAML file'
    task :import, [:filename] => [:environment] do |_, arguments|
      RoleImportExport.new.import(arguments[:filename])
    end

    desc 'Exports all roles to a YAML file'
    task :export, [:filename] => [:environment] do |_, arguments|
      RoleImportExport.new.export(arguments[:filename])
    end

  end
end
