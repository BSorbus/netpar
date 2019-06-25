class AddProvinceToExam < ActiveRecord::Migration
  def change
    add_column :exams, :province_id, :integer
  end
end
