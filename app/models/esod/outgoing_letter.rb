class Esod::OutgoingLetter < ActiveRecord::Base

  has_many :esod_outgoing_letters_matters, class_name: 'Esod::OutgoingLettersMatter', foreign_key: :esod_outgoing_letter_id 
  has_many :esod_matters, through: :esod_outgoing_letters_matters

end
