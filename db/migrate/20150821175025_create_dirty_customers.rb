class CreateDirtyCustomers < ActiveRecord::Migration
  def change
    create_table :dirty_customers do |t|
      t.boolean :human,                                       null: false, default: true
      t.string :name, index: true,                limit: 160, null: false, default: ""
      t.string :given_names, index: true,         limit: 50
      t.string :address_city, index: true,        limit: 50
      t.string :address_street,                   limit: 50 
      t.string :address_house,                    limit: 10
      t.string :address_number,                   limit: 10 
      t.string :address_postal_code,              limit: 6
      t.string :address_post_office,              limit: 50
      t.string :address_pobox,                    limit: 10
      t.string :c_address_city,                   limit: 50
      t.string :c_address_street,                 limit: 50 
      t.string :c_address_house,                  limit: 10
      t.string :c_address_number,                 limit: 10 
      t.string :c_address_postal_code,            limit: 6
      t.string :c_address_post_office,            limit: 50
      t.string :c_address_pobox,                  limit: 10
      t.string :nip, index: true,                 limit: 13
      t.string :regon, index: true,               limit: 9
      t.string :pesel, index: true,               limit: 11
      t.string :dowod_osobisty
      t.references :nationality, index: true, foreign_key: true
      t.references :citizenship, index: true, foreign_key: true
      t.date :birth_date
      t.string :birth_place,                      limit: 50
      t.string :fathers_name,                     limit: 50
      t.string :mothers_name,                     limit: 50
      t.string :phone,                            limit: 50
      t.string :fax,                              limit: 50
      t.string :email,                            limit: 50
      t.text :note
      t.references :user, index: true, foreign_key: true
      t.integer :code
      t.integer :customer_id

      t.timestamps
    end
    #add_index :companies, [:name, :user_id],      unique: true
  end  
end
