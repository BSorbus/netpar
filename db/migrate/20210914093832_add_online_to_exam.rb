class AddOnlineToExam < ActiveRecord::Migration
  def change
    add_column :exams, :online, :boolean, null: false, default: false
  end
end
