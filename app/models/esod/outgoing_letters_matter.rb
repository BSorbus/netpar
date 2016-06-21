class Esod::OutgoingLettersMatter < ActiveRecord::Base
  belongs_to :esod_outgoing_letter, class_name: "Esod::OutgoingLetter", foreign_key: :esod_outgoing_letter_id
  belongs_to :esod_matter, class_name: "Esod::Matter", foreign_key: :esod_matter_id


end
