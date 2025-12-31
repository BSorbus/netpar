class AddColsToExamFees < ActiveRecord::Migration
  def change
    add_column :exam_fees, :valid_from, :date
    add_column :exam_fees, :valid_to, :date
    add_reference :exam_fees, :user, index: true, foreign_key: true
  end
end
