class AddCitizenshipCodeToCustomer < ActiveRecord::Migration
  def up
    add_column :customers, :citizenship_code, :string
  end

  def down
    remove_column :customers, :citizenship_code
  end
end
