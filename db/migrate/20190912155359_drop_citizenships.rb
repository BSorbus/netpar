class DropCitizenships < ActiveRecord::Migration
  def up
    drop_table :citizenships if (table_exists? :citizenships)
  end

  def down
    #raise ActiveRecord::IrreversibleMigration
  end
end
