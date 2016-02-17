class RemoveShortFromDivision < ActiveRecord::Migration
  def change
    remove_column :divisions, :short, :string
  end
end
