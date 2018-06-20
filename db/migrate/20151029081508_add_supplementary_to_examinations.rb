class AddSupplementaryToExaminations < ActiveRecord::Migration
  def change
    add_column :examinations, :supplementary, :boolean, null: false, default: false
  end
end
