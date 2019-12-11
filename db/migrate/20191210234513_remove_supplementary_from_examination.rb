class RemoveSupplementaryFromExamination < ActiveRecord::Migration
  def change
    remove_column :examinations, :supplementary, :boolean
  end
end
