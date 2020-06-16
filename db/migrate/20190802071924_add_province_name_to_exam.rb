class AddProvinceNameToExam < ActiveRecord::Migration
  def change
    add_column :exams, :province_name, :string, limit: 50, default: '', index: true
  end
end
