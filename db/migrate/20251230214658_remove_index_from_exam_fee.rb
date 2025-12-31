class RemoveIndexFromExamFee < ActiveRecord::Migration
  def up
    remove_index :exam_fees, [:division_id, :esod_category]
  end

  def down
    add_index :exam_fees, [:division_id, :esod_category], unique: true      
  end
end
