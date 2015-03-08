class ButtonsImportExport

  def import(filename)
    raise "Must supply filename" if filename.blank?
    contents = YAML.load_file(filename)
    CustomButton.transaction do
      import_custom_button_sets(contents[:custom_buttons_sets])
    end
  end

  def export(filename)
  raise "Must supply filename" if filename.blank?
  custom_buttons_sets_hash = export_custom_button_sets(CustomButtonSet.in_region(MiqRegion.my_region_number))
  custom_button_find = CustomButton.in_region(MiqRegion.my_region_number)
  bf_array = []
  custom_button_find.each do |bf|
    if bf['applies_to_class'] != "ServiceTemplate"
      puts bf.inspect
      bf_array << bf
    end
  end
  #custom_buttons_hash = export_custom_buttons(bf_array)

  #custom_buttons_hash = export_custom_buttons(CustomButton.in_region(MiqRegion.my_region_number))
  puts custom_buttons_sets_hash.inspect
  puts "Filename: #{filename}"
  File.write(filename, {:custom_buttons_sets => custom_buttons_sets_hash}.to_yaml)
  end

  private

  def import_resource_actions(resource_actions, cbs)
    puts ResourceAction.methods.sort
    puts resource_actions.inspect
    resource_actions.each do |ra|
      resource_action = cbs.resource_actions.find_by_action(ra['action'])
      resource_action = cbs.resource_actions.new unless resource_action

      dialog_label = ra.delete('dialog_label')
      unless dialog_label.blank?
        dialog = Dialog.in_region(MiqRegion.my_region_number).find_by_label(dialog_label)
        raise "Unable to locate dialog: [#{dialog_label}]" unless dialog
        ra['dialog_id'] = dialog.id
      end

      resource_action.update_attributes!(ra)
    end
  end


  def import_custom_buttons(custom_buttons, cbs, parent)
    puts "ParentID: #{parent['id'].inspect}"
    custom_buttons.each do |cb|
     # import_resource_actions(cb, cbs)
     # button = cb
     # puts "Button: [#{cb['name']}]"
     # puts "inspect: #{cb.inspect}"
     # ra = cb['resource_actions']
     # puts "ra: #{ra.inspect}"
     # import_resource_actions(cb['resource_actions'], custom_button)
      cb.delete('resource_actions')
      custom_button = parent.custom_buttons.find { |x| x.name == cb['name'] }
      custom_button = CustomButton.new(:applies_to_id => "#{parent['id']}") unless custom_button
      # button['resource_actions'] = ra
      # puts "button: #{button.inspect}"
      custom_button.update_attributes!(cb)
      #  custom_button.update_attributes!(cb)
      custom_button.save!
      parent.add_member(custom_button) if parent.respond_to?(:add_member)
      #puts parent.inspect
    end
  end

  def import_custom_button_sets(custom_button_sets)
    custom_button_sets.each do |cbs|
      puts "Button Group: [#{cbs['name'].split('|').first}]"
      puts cbs.inspect
      custom_button_set = CustomButtonSet.in_region(MiqRegion.my_region_number).find_by_name(cbs['name'])
      custom_button_set = CustomButtonSet.new unless custom_button_set
      custom_buttons = cbs.delete('custom_buttons')
      set_data = cbs.delete('set_data')
      custom_button_set.update_attributes!(cbs)
      custom_button_set.reload
      import_custom_buttons(custom_buttons, cbs, custom_button_set)
      import_custom_button_set_set_data(set_data, cbs, custom_button_set)
      custom_button_set.save!
    end
  end

  def import_custom_button_set_set_data(set_data, cbs, custom_button_set)
    set_data[:button_order] = set_data[:button_order].collect do |name|
      child_button = custom_button_set.custom_buttons.find { |x| x.name == name }
      child_button.id if child_button
    end.compact
    puts custom_button_set.inspect
    set_data[:applies_to_class] = cbs['name'].split('|').second
    # set_data[:applies_to_id] = custom_button_set.id
    custom_button_set.set_data = set_data
  end

  def export_custom_buttons(custom_buttons)
    buttons = []
    custom_buttons.each do |b|
      button = {}
      custom_buttons.collect do |custom_button|
        button = custom_button.attributes.slice(
            'description', 'applies_to_class', 'applies_to_exp', 'options', 'userid',
            'wait_for_complete', 'name', 'visibility', 'applies_to_id')
        button['resource_actions'] = export_resource_actions(custom_button.resource_action)
        buttons << button
      end
      return buttons
    end
  end

  def export_custom_button_set_data(set_data)
    set_data.reject! { |k,v| [:applies_to_class, :applies_to_id].include?(k) }
    set_data[:button_order] = set_data[:button_order].collect do |button|
      b = CustomButton.find_by_id(button)
      b.name if b
    end.compact
    set_data
  end

  def export_custom_button_sets(custom_button_sets)
    custom_button_sets.collect do |custom_button_set|
      attributes = custom_button_set.attributes.slice('name', 'description', 'set_type', 'read_only', 'mode')
      attributes['custom_buttons'] = export_custom_buttons(custom_button_set.custom_buttons)
      attributes['set_data'] = export_custom_button_set_data(custom_button_set.set_data)
      attributes
    end
  end

  def export_resource_actions(resource_actions)
    attributes = {}
    puts resource_actions.inspect
    attributes['action'] = resource_actions['action']
    attributes['ae_namespace'] = resource_actions['ae_namespace']
    attributes['ae_class'] = resource_actions['ae_class']
    attributes['ae_instance'] = resource_actions['ae_instance']
    attributes['ae_message'] = resource_actions['ae_message']
    attributes['ae_attributes'] = resource_actions['ae_attributes']
    attributes['dialog_label'] = resource_actions.dialog.label if resource_actions.dialog
    attributes
  end

end

namespace :rhconsulting do
  namespace :buttons do

    desc 'Usage information'
    task :usage => [:environment] do
      puts 'Export - Usage: rake rhconsulting:buttons:export[/path/to/export]'
      puts 'Import - Usage: rake rhconsulting:buttons:import[/path/to/export]'
    end

    desc 'Import all dialogs from a YAML file'
    task :import, [:filename] => [:environment] do |_, arguments|
      ButtonsImportExport.new.import(arguments[:filename])
    end

    desc 'Exports all dialogs to a YAML file'
    task :export, [:filename] => [:environment] do |_, arguments|
      ButtonsImportExport.new.export(arguments[:filename])
    end

  end
end
