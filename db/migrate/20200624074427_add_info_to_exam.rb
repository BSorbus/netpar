class AddInfoToExam < ActiveRecord::Migration
  def change
    add_column :exams, :info, :string, default: ""
  end
end
