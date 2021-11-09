class AddAccessCodeToGrade < ActiveRecord::Migration
  def change
    add_column :grades, :testportal_access_code_id, :string, default: "", index:true
  end
end
