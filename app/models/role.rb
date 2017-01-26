class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  has_many :works, as: :trackable


  # validates
  validates :name, presence: true,
                    length: { in: 1..100 },
                    :uniqueness => { :case_sensitive => false }


  # scopes
  scope :by_name, -> { order(:name) }


  def fullname_and_id
    "#{name} (#{id})"
  end

  
end
