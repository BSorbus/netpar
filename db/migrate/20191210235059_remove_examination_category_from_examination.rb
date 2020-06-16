class RemoveExaminationCategoryFromExamination < ActiveRecord::Migration
  def change
    remove_column :examinations, :examination_category, :string
  end
end
