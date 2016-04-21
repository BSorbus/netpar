class Esod::InternalLetter < ActiveRecord::Base

  has_many :esod_internal_letters_matters, class_name: 'Esod::InternalLettersMatter', foreign_key: :esod_internal_letter_id 
  has_many :esod_matters, through: :esod_internal_letters_matters

end
