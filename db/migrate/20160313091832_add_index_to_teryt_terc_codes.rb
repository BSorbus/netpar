class AddIndexToTerytTercCodes < ActiveRecord::Migration
  def change
    add_index :teryt_terc_codes, :woj
    add_index :teryt_terc_codes, :pow
    add_index :teryt_terc_codes, :gmi
  end
end
