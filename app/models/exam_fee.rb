class ExamFee < ActiveRecord::Base
  belongs_to :division

  has_many :proposals  

  # validates
  validates :esod_category, presence: true, uniqueness: { :case_sensitive => false, :scope => [:division_id] }
  validates :division, presence: true

end
