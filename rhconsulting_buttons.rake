  class ButtonsImportExport

    def import(filename)
      raise "Must supply filename" if filename.blank?
      contents = YAML.load_file(filename)
      #CustomButton.transaction do
      #  import_custom_buttons(contents[:custom_buttons])
      #end
      CustomButton.transaction do
        import_custom_button_sets(contents[:custom_buttons_sets])
      end
    end

    def export(filename)
      raise "Must supply filename" if filename.blank?
      custom_buttons_sets_hash = export_custom_button_sets(CustomButtonSet.in_region(MiqRegion.my_region_number))
      custom_buttons_hash = export_custom_buttons(CustomButton.in_region(MiqRegion.my_region_number))
      #puts custom_buttons_sets_hash.inspect
      #puts custom_buttons_hash.inspect
      #File.write(filename, {:custom_buttons_sets => custom_buttons_sets_hash, :custom_buttons => custom_buttons_hash}.to_yaml)
      puts "Writing to file: #{filename}"
      File.write(filename, {:custom_buttons_sets => custom_buttons_sets_hash}.to_yaml)
    end

    private


  def import_custom_buttons(custom_buttons, template, parent)
    custom_buttons.each do |cb|
      puts "Button: [#{cb['name']}]"
      custom_button = parent.custom_buttons.find { |x| x.name == cb['name'] }
      #custom_button = CustomButton.new(:applies_to => template) unless custom_button
      custom_button.update_attributes!(cb)
      parent.add_member(custom_button) if parent.respond_to?(:add_member)
    end
  end

    def import_custom_button_sets(custom_button_sets)
      custom_button_sets.each do |cbs|
        puts "Button Group: [#{cbs['name'].split('|').first}]"

        #puts cbs.inspect
        custom_button_set = CustomButtonSet.in_region(MiqRegion.my_region_number).find_by_name(cbs['name'])
        custom_button_set = CustomButtonSet.new unless custom_button_set
        
        custom_buttons = cbs.delete('custom_buttons')
        set_data = cbs.delete('set_data')
        #puts custom_button_set.inspect
        custom_button_set.update_attributes!(cbs)

        # Need to check if we need to pass in the template argument
        import_custom_buttons(custom_buttons, nil, custom_button_set)

        custom_button_set.reload
        #puts set_data.inspect
        # Need to check if we need to pass in the template argument
        import_custom_button_set_set_data(set_data, nil, custom_button_set)
        custom_button_set.save!
      end
    end

  def import_custom_button_set_set_data(set_data, template, custom_button_set)
    set_data[:button_order] = set_data[:button_order].collect do |name|
      child_button = custom_button_set.custom_buttons.find { |x| x.name == name }
      child_button.id if child_button
    end.compact
    set_data[:applies_to_class] = 'Vm'
    #set_data[:applies_to_id] = template.id
    custom_button_set.set_data = set_data
  end

    def export_custom_buttons(custom_buttons)
      custom_buttons.collect do |custom_button|
     custom_button.attributes.slice(
         'description', 'applies_to_class', 'applies_to_exp', 'options', 'userid',
         'wait_for_complete', 'name', 'visibility', 'applies_to_id')
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
