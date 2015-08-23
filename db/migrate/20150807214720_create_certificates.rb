class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.string :number,                           limit: 30, null: false, default: ""
      t.date :date_of_issue
      t.date :valid_thru
      t.string :certificate_status,               limit: 1, null: false, default: "N"
      t.references :division, index: true, foreign_key: true
      t.references :exam, index: true, foreign_key: true
      t.references :customer, index: true, foreign_key: true
      t.text :note
      t.string :category
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :certificates, [:number, :category],       unique: true
  end  
end
