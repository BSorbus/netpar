class AddShortNameToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :short_name, :string
  end
end
