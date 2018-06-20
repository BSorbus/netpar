class Esod::MatterNote < ActiveRecord::Base
  belongs_to :esod_matter, class_name: "Esod::Matter", foreign_key: :esod_matter_id

end
