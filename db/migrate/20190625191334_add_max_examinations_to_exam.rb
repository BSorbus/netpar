class AddMaxExaminationsToExam < ActiveRecord::Migration
  def change
    add_column :exams, :max_examinations, :integer
  end
end
