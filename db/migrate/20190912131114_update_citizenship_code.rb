class UpdateCitizenshipCode < ActiveRecord::Migration
  def up
    Citizenship.all.each do |rec|
      Customer.where(citizenship_id: rec.id).update_all(citizenship_code: rec.short)
    end
  end

  def down
  end

end