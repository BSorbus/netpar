class UpdateUserWso2Name < ActiveRecord::Migration
  def up
    User.all.each do |rec|
      rec.update_columns(wso2_name: "#{rec.name.mb_chars.downcase}")
    end
  end

  def down
  end
end
