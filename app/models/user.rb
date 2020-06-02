#require 'openssl'
require 'base64'


class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :rememberable, :omniauthable
  devise  :database_authenticatable, 
          :recoverable, 
          :timeoutable, 
          :registerable, 
          :confirmable, 
  		    :trackable, 
          :validatable,
          :lockable,
            :password_expirable,
            :secure_validatable, 
            :password_archivable, 
            :expirable,
          :authentication_keys => [:email]

  #gem 'devise_security_extension'
  #devise :password_expirable, 
  #        :secure_validatable, 
  #        :password_archivable, 
  #        :session_limitable, 
  #        :expirable

	#validates_format_of :email, :with =>  /\A[\w+\-.]+@uke.gov.pl/i
  #validates define in /config/initializers/device.rb -> config.email_regexp = /\A([\w\.%\+\-]+)@uke\.gov\.pl\z/i

  validates :authentication_token, uniqueness: true, allow_blank: true

  has_and_belongs_to_many :roles

  belongs_to :department
  has_many :certificates
  has_many :customers
  has_many :exams

  has_many :documents, as: :documentable

  has_many :works
  has_many :works, as: :trackable
  has_many :trackables, class_name: 'Work', primary_key: 'id', foreign_key: 'user_id'

  scope :by_name, -> { order(:name) }


  before_destroy :user_has_a_history_of_activity, prepend: true
  before_create :generate_authentication_token!

  def user_has_a_history_of_activity
    analize_value = true
    if Work.where(user_id: id).any? 
      errors[:base] << "Nie można usunąć konta użytkownika, który aktywnie wprowadzał/aktualizował dane i działalność ta jest odnotowana w hitorii wpisów"
      analize_value = false
    end
    #if Family.where(company_id: id).any? 
    #  errors[:base] << "Nie można usunąć Firmy, która ma przypisane Polisy Rodzina"
    #  analize_value = false
    #end
    analize_value
  end

  # Getter
  def esod_password
    ''
  end

  # Setter
  def esod_password=(esod_password)
    self.esod_encryped_password = Rails.application.secrets[:esod_with_wso2is] ? encrypt_esod_aes_pass(esod_password) : encrypt_esod_pass(esod_password)
    #self.esod_encryped_password = encrypt_esod_pass(esod_password)
  end

  def encrypt_esod_pass(str)
    secret_key = Rails.application.secrets[:esod_secret_key_for_generate_user_token]
    salt = Digest::MD5.hexdigest(secret_key)
    Digest::SHA512.hexdigest(salt+str)
  end

  def encrypt_esod_aes_pass(str)
    cipher = OpenSSL::Cipher::AES128.new(:CBC)
    cipher.encrypt
    iv = OpenSSL::Random.random_bytes(cipher.iv_len)
    cipher.iv = iv
    cipher.key = Rails.application.secrets[:esod_secret_key_for_generate_user_token][0..15] #KEY
    str = iv + str
    data = cipher.update(str) + cipher.final
    #Base64.urlsafe_encode64(data)
    #Base64.urlsafe_encode64(data).gsub('=', '.').gsub('-', '_')    
    # 2020-05-18
    ret = Base64.encode64(data)
    ret = ret.gsub('+', '_')
    ret = ret.gsub('/', '-')
    ret = ret.gsub('=', '.')
  end

  def generate_authentication_token!
    begin
      self.authentication_token = Devise.friendly_token
    end while self.class.exists?(authentication_token: authentication_token)
  end

  def fullname
    "#{name} (#{email})"
  end

  def fullname_and_id
    "#{name} - #{email} (#{id})"
  end


  # instead of deleting, indicate the user requested a delete & timestamp it  
  def soft_delete  
    update_attribute(:deleted_at, Time.current)  
  end  

  # ensure user account is active  
  def active_for_authentication?  
    super && !deleted_at
  end  

  # provide a custom message for a deleted account   
  def inactive_message
    !deleted_at ? super : :deleted_account  
  end  

  # Integration with ActiveJob
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # Override Devise::Confirmable#after_confirmation
  def after_confirmation
    super
    Work.create( trackable_id: self.id, trackable_type: 'User', trackable_url: "#{Rails.application.routes.url_helpers.user_path(self)}", action: :account_confirmation, user_id: self.id, 
      parameters: {id: self.id, name: self.name, email: self.email}.to_json )
  end


  #  Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  #    #if record.respond_to?(:update_tracked_fields!) && warden.authenticated?(options[:scope]) && !warden.request.env['devise.skip_trackable']
  #    #  record.update_tracked_fields!(warden.request)
  #    #end
  #    #your custom code
  #      puts "##########################################################"
  #      puts "# Warden::Manager.after_set_user "
  #      puts "user : ============>"
  #      puts user
  #      puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  #      puts "auth : ============>"
  #      puts auth
  #      puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  #      puts "opts : ============>"
  #      puts opts
  #      #puts Warden::Manager.request.remote_ip
  #      puts "##########################################################"
  #    #super
  #  end
  #
  #
  #  # this gets called every time a user is authenticated
  #  # either via an actual sign in or through a cookie
  #  Warden::Manager.after_authentication do |user,auth,opts|
  #    auth.params.has_key?('user') ? 'trigger direct sign in' : 'trigger cookie sign in'
  #      puts "##########################################################"
  #      puts "# Warden::Manager.after_authentication "
  #      puts "user : ============>"
  #      puts user
  #      puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  #      puts "auth : ============>"
  #      puts auth
  #      puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  #      puts "opts : ============>"
  #      puts opts
  #      puts "##########################################################"
  #
  #  end


  # this gets called every time a request fails due to lacking authentication
  Warden::Manager.before_failure do |env, opts|
    # parse params
    # Rack::Request.new(env).params

    # authentication failed:
    # opts == {:scope=>:user, :recall=>"devise/sessions#new", :action=>"unauthenticated", :attempted_path=>"/users/sign_in"}

    # redirect as a user is required
    # opts == {:scope=>:user, :action=>"unauthenticated", :attempted_path=>"/"}
    # 'trigger sign in failed' if opts.has_key?(:recall)

      my_hash = opts
      my_hash[:REMOTE_ADDR] = env["REMOTE_ADDR"]
      my_hash[:REQUEST_URI] = env["REQUEST_URI"]
      #my_hash["rack.session"] = env["rack.session"] # za dużo danych

      # usuwa "password" z hasha
      my_hash["rack.request.form_hash"] = Hash[env["rack.request.form_hash"].map {|k,v| [k,(v.respond_to?(:except)?v.except("password"):v)] }] if env["rack.request.form_hash"].present?
      # get a flash notice! 
      my_hash["flash"] = deep_find(:flash, env["rack.session"], found=nil) 

      Work.create( action: :unauthenticated, user_id: nil, parameters: my_hash.to_json ) if opts.has_key?(:recall)
  end

  #Warden::Manager.after_failed_fetch do |user, auth, opts|
  #  #your custom code
  #    puts "##########################################################"
  #    puts "# Warden::Manager.after_failed_fetch "
  #    puts user
  #    puts auth
  #    puts opts
  #    puts "##########################################################"
  #  #'trigger user request'
  #end


  def self.deep_find(key, object=self, found=nil)
    if object.respond_to?(:key?) && object.key?(key)
      return object[key]
    elsif object.is_a? Enumerable
      object.find { |*a| found = deep_find(key, a.last) }
      return found
    end
  end


end
