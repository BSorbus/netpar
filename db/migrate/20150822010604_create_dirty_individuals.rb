class CreateDirtyIndividuals < ActiveRecord::Migration
  def change
    create_table :dirty_individuals do |t|
      t.string :number, limit: 30
      t.date :date_of_issue
      t.date :valid_thru
      t.string :license_status, limit: 1
      t.date :application_date
      t.string :call_sign, limit: 20
      t.string :category, limit: 1
      t.integer :transmitter_power
      t.string :certificate_number
      t.date :certificate_date_of_issue
      #t.references :certificate, index: true, foreign_key: true
      t.string :payment_code
      t.date :payment_date
      t.text :note
      t.references :dirty_customer, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :code

      t.timestamps null: false
    end
  end
end
