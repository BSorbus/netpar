class Esod::InternalLetter < ActiveRecord::Base
  has_many :esod_internal_letters_matters, class_name: 'Esod::InternalLettersMatter', foreign_key: :esod_internal_letter_id 
  has_many :esod_matters, through: :esod_internal_letters_matters

  # callbacks
  # push data to ESOD after mamy_to_many (esod_incoming_letters_matters) created
  #before_save :insert_data_to_esod_and_update_self, on: :create, if: "initialized_from_esod == false"



end

