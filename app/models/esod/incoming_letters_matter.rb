class Esod::IncomingLettersMatter < ActiveRecord::Base
  belongs_to :esod_incoming_letters, class_name: "Esod::IncomingLetter", foreign_key: :esod_incoming_letter_id
  belongs_to :esod_matters, class_name: "Esod::Matter", foreign_key: :esod_matter_id

#  has_and_belongs_to_many :esod_matters, class_name: "Esod::Matter", foreign_key: :esod_incoming_letter_id, 
#    association_foreign_key: :esod_matter_id, join_table: :esod_incoming_letters_matters

end
