class AddPocztaToEsodAddress < ActiveRecord::Migration
  def change
    add_column :esod_addresses, :miasto_poczty, :string
  end
end
