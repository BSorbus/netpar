class AddIndexToTerytUlicCode < ActiveRecord::Migration
  def change
    add_index :teryt_ulic_codes, :woj
    add_index :teryt_ulic_codes, :pow
    add_index :teryt_ulic_codes, :gmi
    add_index :teryt_ulic_codes, :sym
  end
end
