class AddCitizenshipCodeToCustomer < ActiveRecord::Migration
  def up
    add_column :customers, :citizenship_code, :string

    Citizenship.all.each do |rec|
      Customer.where(citizenship_id: rec.id).update_all(citizenship_code: rec.short)
    end
  end

  def down
    remove_column :customers, :citizenship_code
  end

end
