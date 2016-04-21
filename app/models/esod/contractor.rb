class Esod::Contractor < ActiveRecord::Base
  has_one :customer, foreign_key: :esod_contractor_id, dependent: :nullify
  has_many :esod_incoming_letters, class_name: 'Esod::IncomingLetter', primary_key: 'id', foreign_key: 'esod_contractor_id'


  def fullname
    "#{nazwisko} #{imie} #{nazwa} #{pesel}".strip
  end

end