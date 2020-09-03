class UpdateProvinceIdToExam < ActiveRecord::Migration
  def up
    Exam.where.not(province_name: '').each do |rec|
      set_data_into_province_id(rec)
    end
  end

  def down
    Exam.all.each do |rec|
      rec.update_columns(province_id: '')
    end
  end

  def set_data_into_province_id(current_row)
    province = "#{current_row.province_name.mb_chars.upcase.to_s}"

    province_obj = ApiTerytProvince.new(q: "#{province}") 
    province_obj.request_for_collection
    province_hash = JSON.parse(province_obj.response.body)

    if province_hash.fetch('items', {}).size > 0
      province_items_array = province_hash.fetch('items', {})

      selected = province_items_array.select{|value| value['name'] == "#{province}" }

      if selected.size == 0
        puts '  ERROR selected.size == 0'
        puts '  province_hash:'
        puts province_hash
      else
        if selected.size > 1
          puts '  ERROR selected.size > 1'
          puts '  province_hash:'
          puts province_hash
          puts '  selected:'
          puts selected
          #sleep 10
        else
          id = selected.first.fetch('id', '')
          puts "#{id}"
          current_row.update_columns(province_id: "#{id}", province_name: "#{province}")
        end
      end
    else
      puts "NOT FOUND -> address_hash.fetch('items', {}).size = 0"
      puts "  current_row.id: #{current_row.province_name}"
    end
  end
end
