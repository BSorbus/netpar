class AddPriceUnder18ToExamFees < ActiveRecord::Migration
  def change
    add_column :exam_fees, :price_under18, :decimal, precision: 8, scale: 2
  end
end
