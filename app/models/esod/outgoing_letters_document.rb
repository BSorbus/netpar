class Esod::OutgoingLettersDocument < ActiveRecord::Base
  belongs_to :esod_outgoing_letter, class_name: "Esod::OutgoingLetter", foreign_key: :esod_outgoing_letter_id
  belongs_to :document

end

