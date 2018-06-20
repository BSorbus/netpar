class AddCodeToExam < ActiveRecord::Migration
  def change
    add_column :exams, :code, :integer
  end
end
