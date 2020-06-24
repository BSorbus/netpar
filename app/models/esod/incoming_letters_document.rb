class Esod::IncomingLettersDocument < ActiveRecord::Base
  belongs_to :esod_incoming_letter, class_name: "Esod::IncomingLetter", foreign_key: :esod_incoming_letter_id
  belongs_to :document

end

