class Subject < ActiveRecord::Base
  belongs_to :division

  has_many :grades, dependent: :destroy  

end
