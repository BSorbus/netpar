class Esod::InternalLettersDocument < ActiveRecord::Base
  belongs_to :esod_internal_letter, class_name: "Esod::InternalLetter", foreign_key: :esod_internal_letter_id
  belongs_to :document

end

