class RemoveIndexEnglishNameFromDivision < ActiveRecord::Migration
  def up
    remove_index :divisions, [:english_name, :category]    
  end

  def down
    add_index :divisions, [:english_name, :category],   unique: true    
  end
end
