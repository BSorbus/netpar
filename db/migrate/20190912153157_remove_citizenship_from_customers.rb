class RemoveCitizenshipFromCustomers < ActiveRecord::Migration
  def change
    remove_reference :customers, :citizenship, index: true, foreign_key: true
  end
end
