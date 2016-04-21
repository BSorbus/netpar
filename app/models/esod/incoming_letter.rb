class Esod::IncomingLetter < ActiveRecord::Base
  belongs_to :esod_contractor, class_name: 'Esod::Contractor'
  belongs_to :esod_address, class_name: 'Esod::Address'

  has_many :esod_incoming_letters_matters, class_name: 'Esod::IncomingLettersMatter', foreign_key: :esod_incoming_letter_id 
  has_many :esod_matters, through: :esod_incoming_letters_matters

#  has_and_belongs_to_many :esod_matters, class_name: "Esod::Matter", foreign_key: :esod_incoming_letter_id, 
#    association_foreign_key: :esod_matter_id, join_table: :esod_incoming_letters_matters

end
