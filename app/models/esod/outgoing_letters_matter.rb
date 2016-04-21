class Esod::OutgoingLettersMatter < ActiveRecord::Base
  belongs_to :esod_outgoing_letters, class_name: "Esod::OutgoingLetter", foreign_key: :esod_outgoing_letter_id
  belongs_to :esod_matters, class_name: "Esod::Matter", foreign_key: :esod_matter_id

#  has_and_belongs_to_many :esod_matters, class_name: "Esod::Matter", foreign_key: :esod_outgoing_letter_id, 
#    association_foreign_key: :esod_matter_id, join_table: :esod_outgoing_letters_matters

end
