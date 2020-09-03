class AddAndRemoveFieldsToExam < ActiveRecord::Migration
  def up
  	remove_column :exams, :province_id
    add_column :exams, :province_id, :string, limit: 2, default: "", null: false
  end

  def down
  	remove_column :exams, :province_id
    add_column :exams, :province_id, :int
  end
end
