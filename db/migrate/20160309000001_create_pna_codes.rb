class CreatePnaCodes < ActiveRecord::Migration
  def change
    create_table :pna_codes do |t|
      t.string :pna
      t.string :miejscowosc
      t.string :ulica
      t.string :numery
      t.string :wojewodztwo
      t.string :powiat
      t.string :gmina

      t.timestamps null: false
    end
    add_index :pna_codes, [:pna]
    add_index :pna_codes, [:miejscowosc]
    add_index :pna_codes, [:wojewodztwo]
    add_index :pna_codes, [:powiat]
    add_index :pna_codes, [:gmina]
    add_index :pna_codes, [:miejscowosc, :ulica]
  end
end
