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
    custom_buttons_hash = export_custom_buttons(bf_array)

#      custom_buttons_hash = export_custom_buttons(CustomButton.in_region(MiqRegion.my_region_number))
    puts custom_buttons_sets_hash.inspect
#puts custom_buttons_hash.inspect
#File.write(filename, {:custom_buttons_sets => custom_buttons_sets_hash, :custom_buttons => custom_buttons_hash}.to_yaml)
    puts "Filename: #{filename}"
    File.write(filename, {:custom_buttons_sets => custom_buttons_sets_hash}.to_yaml)
  end

  private

  def import_resource_actions(custom_button, resource_actions, cbs)
    #puts ResourceAction.methods.sort
    puts "IMPORT RESOUCE ACTIONS"
    puts resource_actions.class
    puts "IMPORT RESOUCE ACTIONS"
    puts "IMPORT CBS "
    puts cbs.inspect
    puts "IMPORT CBS"
    # {"action"=>nil, "ae_namespace"=>"SYSTEM", "ae_class"=>"PROCESS", "ae_instance"=>"Automation", "ae_message"=>"create", "ae_attributes"=>{"attribute1"=>"value1", "request"=>"/POC/Methods/blah"}, "dialog_label"=>"Infoblox_DNS_Alias"}

    #count = 0
    #cbs.each do | cb_entry |
    #   puts "CBS Entry"
    #   puts cb_entry.class
    #   puts cb_entry.inspect
    #   
    #   if cb_entry['name'] == name
    #      puts "Updating CB Entry"
    #      cb_entry['resource_actions'] = resource_actions
    #      cbs[count]=cb_entry
    #      puts cbs.inspect
    #      puts cb_entry['resource_actions']
    #   end
    #   count += 1
    #end

    #cbs.resource_actions = resource_actions.to_a
    #resource_action = ResourceAction.find_by_action(resource_actions['action'])
    #resource_action = ResourceAction.new unless resource_action
    #cbs(resource_actions.to_a)
    puts "resource_actions: #{resource_actions.inspect}"
    #resource_actions.each do |ra|
    #  puts "ra: #{ra.inspect}"
    puts ResourceAction.inspect
    resource_action = ResourceAction.new


#ResourceAction(id: integer, action: string, dialog_id: integer, resource_id: integer, resource_type: string, created_at: datetime, updated_at: datetime, ae_namespace: string, ae_class: string, ae_instance: string, ae_message: string, ae_attributes: text)
#{"action"=>nil, "ae_namespace"=>"SYSTEM", "ae_class"=>"PROCESS", "ae_instance"=>"Request", "ae_message"=>"create", "ae_attributes"=>{"request"=>"Infoblox_Dialog_List_Networks"}, "dialog_label"=>"Infoblox_Dialog_List_Networks"}

    ra = {}
    ra['action'] = resource_actions['action']
    ra['resource_id'] = custom_button.id
    ra['resource_type'] = "CustomButton"
    ra['ae_namespace'] = resource_actions['ae_namespace']
    ra['ae_class'] = resource_actions['ae_class']
    ra['ae_instance'] = resource_actions['ae_instance']
    ra['ae_message'] = resource_actions['ae_message']
    ra['ae_attributes'] = resource_actions['ae_attributes']
#   ra['dialog'] = nil
#puts ra.inspect
    dialog_label = resource_actions['dialog_label']
    puts "dialog_label: #{dialog_label.inspect}"
    unless dialog_label.nil?
      dialog = Dialog.in_region(MiqRegion.my_region_number).find_by_label(dialog_label)
      puts "dialog: #{dialog.inspect}"
      raise "Unable to locate dialog: [#{dialog_label}]" unless dialog
      ra['dialog_id'] = dialog.id
    end
    resource_action.update_attributes!(ra)
    resource_action.save!
    #puts resource_action.inspect

    #
    #
    #      resource_action.update_attributes!(ra)
    # end
  end


  def import_custom_buttons(custom_buttons, cbs, parent)
    puts "ParentID: #{parent['id'].inspect}"
    count = 0
    custom_buttons.each do |cb|
#      import_resource_actions(cb, cbs)
#  button = cb
#  puts "Button: [#{cb['name']}]"
#  puts "inspect: #{cb.inspect}"
#ra = cb['resource_actions']
#puts "ra: #{ra.inspect}"
#      import_resource_actions(cb['resource_actions'], custom_button)
      resource_actions = cb['resource_actions']
      puts cb['resource_actions'].inspect
      cb.delete('resource_actions')
      custom_button = parent.custom_buttons.find { |x| x.name == cb['name'] }
      custom_button = CustomButton.new(:applies_to_id => "#{parent['id']}") unless custom_button
      #cb['resource_actions'] = ra
      puts "After Import"
      puts cb.inspect
      puts "After Import"
      #  button['resource_actions'] = ra
      #puts "button: #{button.inspect}"
      if !custom_button.nil?
        puts "Updating custom button [#{cb['name']}]"
        puts custom_button.inspect
        custom_button['name'] = cb['name']
        custom_button['description'] = cb['description']
        custom_button['applies_to_class'] = cb['applies_to_class']
        custom_button['applies_to_exp'] = cb['applies_to_exp']
        custom_button['options'] = cb['options']
        custom_button['userid'] = cb['userid']
        custom_button['wait_for_complete'] = cb['wait_for_complete']
        custom_button['visibility'] = cb['visibility']
        custom_button['applies_to_id'] = cb['applies_to_id']
        custom_button['resource_actions'] = cb['resource_actions']
        custom_button.update_attributes!(cb) unless !custom_button.nil?
        puts "Updated custom button [#{cb['name']}]"
        puts custom_button.inspect
#{"description"=>"Test Hover Text", "applies_to_class"=>"Vm", "applies_to_exp"=>nil, "options"=>{:button_image=>1, :display=>true}, "userid"=>"admin", "wait_for_complete"=>nil, "name"=>"Test Button", "visibility"=>{:roles=>["_ALL_"]}, "applies_to_id"=>nil}
        custom_button.save!
        parent.add_member(custom_button) if parent.respond_to?(:add_member)
        custom_buttons[count] = custom_button
        count += 1
        puts custom_buttons.inspect
        puts resource_actions.inspect
        import_resource_actions(custom_button, resource_actions, custom_buttons)
      end
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
      custom_button_set.update_attributes!(cbs)
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
#    set_data[:applies_to_id] = custom_button_set.id
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
      attributes = custom_button_set.attributes.slice(
          'name', 'description', 'set_type', 'read_only', 'mode')
      attributes['custom_buttons'] = export_custom_buttons(custom_button_set.custom_buttons)
      attributes['set_data'] = export_custom_button_set_data(custom_button_set.set_data)
      attributes
    end
  end

  def export_resource_actions(resource_actions)
    attributes = {}
    # Added a check here
    if !resource_actions.nil?
      puts resource_actions.inspect
      attributes['action'] = resource_actions['action']
      attributes['ae_namespace'] = resource_actions['ae_namespace']
      attributes['ae_class'] = resource_actions['ae_class']
      attributes['ae_instance'] = resource_actions['ae_instance']
      attributes['ae_message'] = resource_actions['ae_message']
      attributes['ae_attributes'] = resource_actions['ae_attributes']
      #puts resource_actions.methods
      #puts resource_actions.dialog.inspect
      # puts resource_action.methods
      attributes['dialog_label'] = resource_actions.dialog.label if resource_actions.dialog
      attributes
    end
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
