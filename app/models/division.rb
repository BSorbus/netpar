class Division < ActiveRecord::Base
  has_many :certificates  
  has_many :subjects, dependent: :destroy  

  accepts_nested_attributes_for :subjects

  # validates
  validates :name, presence: true, uniqueness: { :case_sensitive => false, :scope => [:category] }
  validates :category, presence: true, inclusion: { in: %w(L M R) }
  validates :short_name, presence: true
  validates :number_prefix, presence: true


  # scopes
  scope :only_category_scope, ->(cat)  { where(category: cat.upcase) }
  scope :by_name, -> { order(:name) }

end
