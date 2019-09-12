class UpdateCitizenshipCode < ActiveRecord::Migration
  def up
    Citizenship.all.each do |rec|
      Customer.where(citizenship_id: rec.id).each do |customer_rec|
        customer_rec.update_columns(citizenship_code: rec.short)
      end
    end
  end

  def down
  end

end