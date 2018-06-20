class AddNumberPrefixToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :number_prefix, :string
  end
end
