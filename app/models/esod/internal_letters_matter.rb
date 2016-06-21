class Esod::InternalLettersMatter < ActiveRecord::Base
  belongs_to :esod_internal_letter, class_name: "Esod::InternalLetter", foreign_key: :esod_internal_letter_id
  belongs_to :esod_matter, class_name: "Esod::Matter", foreign_key: :esod_matter_id


end
