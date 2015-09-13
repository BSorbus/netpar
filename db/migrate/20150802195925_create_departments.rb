class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :short,                            limit: 10, null: false, default: ""
      t.string :name,                             limit: 100, null: false, default: ""
      t.string :address_city,                     limit: 50, null: false, default: ""
      t.string :address_street,                   limit: 50, null: false, default: "" 
      t.string :address_house,                    limit: 10, null: false, default: ""
      t.string :address_number,                   limit: 10, default: "" 
      t.string :address_postal_code,              limit: 6, null: false, default: ""
      t.string :phone,                            limit: 50, default: ""               
      t.string :fax,                              limit: 50, default: ""               
      t.string :email,                            limit: 50, default: "" 
      t.string :director,                         limit: 50, default: ""
      t.string :code

      t.timestamps null: false
    end

    add_index :departments, [:short],     unique: true
    add_index :departments, [:name],     unique: true
  end
end
