class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.uuid :multi_app_identifier,         null: false, index: true
      t.references :proposal_status, index: true, foreign_key: true
      t.string :category,                   limit: 1, null: false, index: true
      t.references :user, index: true
      t.integer :creator_id
      # customer
      t.string :name,                       limit: 160, default: "",   null: false
      t.string :given_names,                limit: 50,  default: "",   null: false
      t.string :pesel, index: true,         limit: 11, default: ""
      t.date :birth_date
      t.string :birth_place,                limit: 50, default: ""
      #t.references :citizenship, index: true, foreign_key: true, default: 2
      t.string :phone,                      limit: 50, default: ""
      t.string :email,                      limit: 50, default: "",   null: false
      t.string :address_city,               limit: 50, default: "",   null: false
      t.string :address_street,             limit: 50, default: "" 
      t.string :address_house,              limit: 10, default: ""
      t.string :address_number,             limit: 10, default: "" 
      t.string :address_postal_code,        limit: 10, default: ""
      t.string :c_address_city,             limit: 50, default: ""
      t.string :c_address_street,           limit: 50, default: "" 
      t.string :c_address_house,            limit: 10, default: ""
      t.string :c_address_number,           limit: 10, default: "" 
      t.string :c_address_postal_code,      limit: 10, default: ""
      # Exam
      t.integer :esod_category
      t.references :exam, index: true, foreign_key: true
      t.string :exam_fullname
      t.date :date_exam
      t.references :division, index: true, foreign_key: true
      t.string :division_fullname
      t.references :exam_fee, index: true, foreign_key: true
      t.decimal :exam_fee_price, precision: 8, scale: 2, default: 0.00
      t.text :face_image_blob_path
      t.text :bank_pdf_blob_path
      t.text :not_approved_comment
 
      t.timestamps
    end
  end
end