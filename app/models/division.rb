class Division < ActiveRecord::Base
  has_many :certificates  

  scope :only_category_scope, ->(cat)  { where(category: cat.upcase) }
  scope :by_name, -> { order(:name) }

  #scope :only_category_scope, ->(cat) { where( my_sql("#{q}") ) }

end
