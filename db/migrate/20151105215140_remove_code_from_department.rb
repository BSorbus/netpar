class RemoveCodeFromDepartment < ActiveRecord::Migration
  def change
    remove_column :departments, :code, :string
  end
end
