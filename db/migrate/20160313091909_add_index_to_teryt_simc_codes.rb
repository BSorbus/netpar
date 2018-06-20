class AddIndexToTerytSimcCodes < ActiveRecord::Migration
  def change
    add_index :teryt_simc_codes, :woj
    add_index :teryt_simc_codes, :pow
    add_index :teryt_simc_codes, :gmi
    add_index :teryt_simc_codes, :sym
    add_index :teryt_simc_codes, :sympod
  end
end
