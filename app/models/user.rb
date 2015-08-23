class User < ActiveRecord::Base
#  after_initialize :set_default_department, :if => :new_record?

#  def set_default_department
#    self.department ||= Department.first
#  end

  # Include default devise modules. Others available are:
  # :rememberable, :lockable, :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :timeoutable, :confirmable, 
  		:trackable, :validatable, :authentication_keys => [:email]

	#validates_format_of :email, :with =>  /\A[\w+\-.]+@uke.gov.pl/i
  #validacja w /config/initializers/device.rb -> config.email_regexp = /\A([\w\.%\+\-]+)@uke\.gov\.pl\z/i

  has_and_belongs_to_many :roles

  belongs_to :department
  has_many :certificates
  has_many :customers
  has_many :exams

  scope :by_name, -> { order(:name) }


  def roles_used
    #@roles_used ||= self.roles.order(:name)
    @roles_used ||= self.roles.by_name
  end

  def roles_not_used
    # driver Postgres get error if select type ...WHERE ("elements"."id" NOT IN ())
    # driver SQLite3, MySQL working valid
    if roles_used.any?
      #@roles_not_used ||= Role.where.not(id: [roles_used.ids]) DEPRECATE
      @roles_not_used ||= Role.where.not(id: roles_used.map(&:id)).by_name
    else
      @roles_not_used ||= Role.by_name.all
    end
  end


end
