class AddCitizenshipCodeToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :citizenship_code, :string
  end
end
