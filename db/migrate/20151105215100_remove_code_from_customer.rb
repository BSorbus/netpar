class RemoveCodeFromCustomer < ActiveRecord::Migration
  def change
    remove_column :customers, :code, :string
  end
end
