class CreateExamFees < ActiveRecord::Migration
  def up
    create_table :exam_fees do |t|
      t.references :division, foreign_key: true
      t.integer :esod_category
      t.decimal :price, precision: 8, scale: 2

      t.timestamps null: false
    end
    add_index :exam_fees, [:division_id, :esod_category], unique: true

    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'G1E'), price: 225.00)
    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'G2E'), price: 225.00)
    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'GOC'), price: 185.00)
    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'ROC'), price: 165.00)
    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'CSO'), price: 175.00)
    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'IWC'), price: 125.00)
    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'LRC'), price: 145.00)
    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'SRC'), price: 125.00)
    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'VHF'), price: 105.00)

    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'A'), price: 75.00)
    ExamFee.create(esod_category: 41, division: Division.find_by(short_name: 'C'), price: 50.00)
  end

  def down
    remove_index :exam_fees, [:division_id, :esod_category]
    drop_table :exam_fees
  end
end
