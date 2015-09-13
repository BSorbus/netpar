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

  def users_used
    #@users_used ||= self.users.order(:name)
    @users_used ||= self.users.by_name
  end

  def users_not_used
    @users_not_used ||= User.where.not(id: users_used.map(&:id)).by_name
  end

  
end
