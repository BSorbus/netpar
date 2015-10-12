class DropDirtyTable < ActiveRecord::Migration
  def up
    drop_table :h_customers
    drop_table :dirty_individuals
    drop_table :dirty_addresses
    drop_table :dirty_customers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
