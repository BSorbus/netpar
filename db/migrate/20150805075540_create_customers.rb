class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.boolean :human,                                       null: false, default: true
      t.string :name, index: true,                limit: 160, null: false, default: ""
      t.string :given_names, index: true,         limit: 50, default: ""
      t.string :address_city, index: true,        limit: 50, default: ""
      t.string :address_street,                   limit: 50, default: "" 
      t.string :address_house,                    limit: 10, default: ""
      t.string :address_number,                   limit: 10, default: "" 
      t.string :address_postal_code,              limit: 6, default: ""
      t.string :address_post_office,              limit: 50, default: ""
      t.string :address_pobox,                    limit: 10, default: ""
      t.string :c_address_city,                   limit: 50, default: ""
      t.string :c_address_street,                 limit: 50, default: "" 
      t.string :c_address_house,                  limit: 10, default: ""
      t.string :c_address_number,                 limit: 10, default: "" 
      t.string :c_address_postal_code,            limit: 6, default: ""
      t.string :c_address_post_office,            limit: 50, default: ""
      t.string :c_address_pobox,                  limit: 10, default: ""
      t.string :nip, index: true,                 limit: 13, default: ""
      t.string :regon, index: true,               limit: 9, default: ""
      t.string :pesel, index: true,               limit: 11, default: ""
      t.references :nationality, index: true, foreign_key: true, default: 2
      t.references :citizenship, index: true, foreign_key: true, default: 2
      t.date :birth_date, index: true
      t.string :birth_place,                      limit: 50, default: ""
      t.string :fathers_name,                     limit: 50, default: ""
      t.string :mothers_name,                     limit: 50, default: ""
      t.string :phone,                            limit: 50, default: ""
      t.string :fax,                              limit: 50, default: ""
      t.string :email,                            limit: 50, default: ""
      t.text :note,                                         default: ""
      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
    #add_index :companies, [:name, :user_id],      unique: true
  end  
end
