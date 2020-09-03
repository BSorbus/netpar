class DropPnaTeryt < ActiveRecord::Migration
  def up
    drop_table :pna_codes if (table_exists? :pna_codes)
    drop_table :teryt_pna_codes if (table_exists? :teryt_pna_codes)
    drop_table :teryt_simc_codes if (table_exists? :teryt_simc_codes)
    drop_table :teryt_terc_codes if (table_exists? :teryt_terc_codes)
    drop_table :teryt_ulic_codes if (table_exists? :teryt_ulic_codes)
  end

  def down
    #raise ActiveRecord::IrreversibleMigration
  end
end
