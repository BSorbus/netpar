class RemoveCodeFromExam < ActiveRecord::Migration
  def change
    remove_column :exams, :code, :string
  end
end
