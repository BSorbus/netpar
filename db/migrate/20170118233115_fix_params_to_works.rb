require 'json'

class FixParamsToWorks < ActiveRecord::Migration
  def up
#    add_column :works, :extra_info, :jsonb, null: false, default: '{}'

    Work.where(action: ['add_role', 'remove_role']).each do |w|
      if w.parameters.include? ':role=>' or w.parameters.include? ':user=>'
        w.update_attribute :parameters, w.parameters.gsub(':role=>', '"role":').gsub(':user=>', '"user":')   
      end
    end

#    Work.all.each do |w|
#      w.update_attribute :extra_info, w.parameters 
#    end

#        puts w.parameters.as_json
#        puts w.parameters.to_json
#        sleep 10
#        w.update_attribute :extra_info, w.parameters.as_json   
#        w.update_attribute :parameters_fix, w.parameters   
#        w.update_attribute :extra_info, w.parameters 

#    add_index  :works, :extra_info, using: :gin

#    execute <<-SQL
#      CREATE INDEX work_extra_info_action_index ON works ((extra_info->>'action'))
#    SQL

  end

  def down
    remove_column :works, :extra_info
  end
end
