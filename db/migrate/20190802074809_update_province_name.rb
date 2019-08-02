class UpdateProvinceName < ActiveRecord::Migration
  def up
    Exam.where('province_id IS NOT NULL AND province_id > 0').each do |e|
      e.update_columns(province_name: set_province_name(e))
    end
  end

  def down
  end

  def set_province_name(current_row)
    puts "id: #{current_row.id}, province_id: #{current_row.province_id}"
    province = PitTerytProvince.new(id: current_row.province_id)
    province.run_request
    puts "province_name: #{province.name}"
    puts ""
    province.name    
  end
end
