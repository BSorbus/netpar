class Examiner < ActiveRecord::Base
  belongs_to :exam

  validates :name, presence: true,
                    length: { in: 1..50 },
                    :uniqueness => { :case_sensitive => false, :scope => [:exam] }

end
