class Esod::Address < ActiveRecord::Base
  belongs_to :customer#, class_name: "Customer", foreign_key: :customer_id#, dependent: :delete

  has_many :esod_incoming_letters, class_name: 'Esod::IncomingLetter', primary_key: 'id', foreign_key: 'esod_address_id'


  def fullname
    res = "#{kod_pocztowy} #{miasto}, #{ulica}"
    res +=  " #{numer_budynku}" if numer_budynku.present?
    res +=  "/#{numer_lokalu}" if numer_lokalu.present?
    res
  end

end

