class CreateIndividuals < ActiveRecord::Migration
  def change
    create_table :individuals do |t|
      t.string :number,                           limit: 30, null: false, default: ""
      t.date :date_of_issue, index: true
      t.date :valid_thru
      t.string :license_status, limit: 1
      t.date :application_date
      t.string :call_sign, index: true, limit: 20
      t.string :category, limit: 1
      t.integer :transmitter_power
      t.string :certificate_number
      t.date :certificate_date_of_issue
      t.references :certificate, index: true, foreign_key: true
      t.string :payment_code
      t.date :payment_date
      #t.references :payment, index: true, foreign_key: true
      t.string :station_city, limit: 50
      t.string :station_street, limit: 50
      t.string :station_house, limit: 10
      t.string :station_number, limit: 10
      t.references :customer, index: true, foreign_key: true
      t.text :note
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :individuals, [:number],       unique: true
  end
end
