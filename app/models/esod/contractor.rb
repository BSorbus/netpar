class Esod::Contractor < ActiveRecord::Base
  belongs_to :customer, class_name: "Customer"#, dependent: :delete

  has_many :esod_incoming_letters, class_name: 'Esod::IncomingLetter', primary_key: 'id', foreign_key: 'esod_contractor_id'

  # callbacks
  #before_save :insert_data_to_esod_and_update_self, on: :create, if: "initialized_from_esod == false"


  def fullname
    "#{nazwisko} #{imie} #{nazwa} #{pesel}".strip
  end

end
