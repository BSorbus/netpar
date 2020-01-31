class AddressTerytPnaCode < ActiveRecord::Base
  self.table_name = 'teryt_pna_codes' 
  #has_many :customers, foreign_key: :address_teryt_pna_code_id, class_name: "Customer"
end