class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.string :department
      t.string :number, index: true
      t.string :status
      t.date :date_of_issue
      t.date :valid_to
      t.string :call_sign, index: true
      t.string :category
      t.integer :transmitter_power
      t.string :name_type_station
      t.string :destination
      t.string :input_frequency
      t.string :output_frequency
      t.string :emission
      t.string :operators, index: true
      t.text :note
      t.string :applicant_name, index: true
      t.string :applicant_location, index: true
      t.string :enduser_name, index: true
      t.string :enduser_location, index: true
      t.string :station_location, index: true
      t.string :type_license, limit: 1, index: true
    end
  end
end
