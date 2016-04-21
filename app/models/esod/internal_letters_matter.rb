class Esod::InternalLettersMatter < ActiveRecord::Base
  belongs_to :esod_internal_letters, class_name: "Esod::InternalLetter", foreign_key: :esod_internal_letter_id
  belongs_to :esod_matters, class_name: "Esod::Matter", foreign_key: :esod_matter_id

#  has_and_belongs_to_many :esod_matters, class_name: "Esod::Matter", foreign_key: :esod_internal_letter_id, 
#    association_foreign_key: :esod_matter_id, join_table: :esod_internal_letters_matters

end
