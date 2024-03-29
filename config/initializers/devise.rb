Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  # Devise will use the `secret_key_base` as its `secret_key`
  # by default. You can change it below and use your own secret key.
  # config.secret_key = '2ca0ba7d6c576873d8258c6896d0cf50e469519139f7a1429a899420345515e42a6a44727667f435ae521567ddf20fb669f48f0ecb0d26d6572111ad3115d680'
    config.secret_key = '3d99097360564ee70f6ee3619f53b46e4cf5880fa60282e7797103659fd88de38f734d2690f92a8009c4d677896fe897ec9d7ebf331339983481a27e4ee27052'

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class
  # with default "from" parameter.
  config.mailer_sender = Rails.application.secrets.email_provider_username

  # Configure the class responsible to send e-mails.
  #config.mailer = 'MyMailer'

  # Configure the parent class responsible to send e-mails.
  # config.parent_mailer = 'ActionMailer::Base'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # You can also supply a hash where the value is a boolean determining whether
  # or not authentication should be aborted when the value is not present.
  config.authentication_keys = [:email]

  # Configure parameters from the request object used for authentication. Each entry
  # given should be a request method and it will automatically be passed to the
  # find_for_authentication method and considered in your model lookup. For instance,
  # if you set :request_keys to [:subdomain], :subdomain will be used on authentication.
  # The same considerations mentioned for authentication_keys also apply to request_keys.
  # config.request_keys = []

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [:email]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is :email.
  config.strip_whitespace_keys = [:email]

  # Tell if authentication through request.params is enabled. True by default.
  # It can be set to an array that will enable params authentication only for the
  # given strategies, for example, `config.params_authenticatable = [:database]` will
  # enable it only for database (email + password) authentication.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Auth is enabled. False by default.
  # It can be set to an array that will enable http authentication only for the
  # given strategies, for example, `config.http_authenticatable = [:database]` will
  # enable it only for database authentication. The supported strategies are:
  # :database      = Support basic authentication with authentication key + password
  # config.http_authenticatable = false

  # If 401 status code should be returned for AJAX requests. True by default.
  # config.http_authenticatable_on_xhr = true

  # The realm used in Http Basic Authentication. 'Application' by default.
  # config.http_authentication_realm = 'Application'

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # config.paranoid = true

  # By default Devise will store the user in session. You can skip storage for
  # particular strategies by setting this option.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing skip: :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # By default, Devise cleans up the CSRF token on authentication to
  # avoid CSRF token fixation attacks. This means that, when using AJAX
  # requests for sign in and sign up, you need to get a new CSRF token
  # from the server. You can disable this option at your own risk.
  # config.clean_up_csrf_token_on_authentication = true

  # When false, Devise will not attempt to reload routes on eager load.
  # This can reduce the time taken to boot the app but if your application
  # requires the Devise mappings to be loaded during boot time the application
  # won't boot properly.
  # config.reload_routes = true

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 11. If
  # using other algorithms, it sets how many times you want the password to be hashed.
  #
  # Limiting the stretches to just one in testing will increase the performance of
  # your test suite dramatically. However, it is STRONGLY RECOMMENDED to not use
  # a value less than 10 in other environments. Note that, for bcrypt (the default
  # algorithm), the cost increases exponentially with the number of stretches (e.g.
  # a value of 20 is already extremely slow: approx. 60 seconds for 1 calculation).
  config.stretches = Rails.env.test? ? 1 : 11

  # Set up a pepper to generate the hashed password.
  # config.pepper = '4cab261a3139897595e303be58790e4e80d11946afe2db888ac98994f1b981b948a846cc025db6c01cf67aa1a510360176e7004c4f222f06d4f11991849fdb07'

  # Send a notification email when the user's password is changed
  # config.send_password_change_notification = false

  # ==> Configuration for :confirmable
  # A period that the user is allowed to access the website even without
  # confirming their account. For instance, if set to 2.days, the user will be
  # able to access the website for two days without confirming their account,
  # access will be blocked just in the third day. Default is 0.days, meaning
  # the user cannot access the website without confirming their account.
  # config.allow_unconfirmed_access_for = 2.days

  # A period that the user is allowed to confirm their account before their
  # token becomes invalid. For example, if set to 3.days, the user can confirm
  # their account within 3 days after the mail was sent, but on the fourth day
  # their account can't be confirmed with the token any more.
  # Default is nil, meaning there is no restriction on how long a user can take
  # before confirming their account.
  # config.confirm_within = 3.days

  # If true, requires any email changes to be confirmed (exactly the same way as
  # initial account confirmation) to be applied. Requires additional unconfirmed_email
  # db field (see migrations). Until confirmed, new email is stored in
  # unconfirmed_email column, and copied to email column on successful confirmation.
  config.reconfirmable = true

  # Defines which key will be used when confirming an account
  # config.confirmation_keys = [:email]

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  # config.remember_for = 2.weeks

  # Invalidates all the remember me tokens when the user signs out.
  config.expire_all_remember_me_on_sign_out = true

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # secure: true in order to force SSL only cookies.
  # config.rememberable_options = {}

  # ==> Configuration for :validatable
  # Range for password length.
  config.password_length = 8..128

  # Email regex used to validate email formats. It simply asserts that
  # one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  # config.email_regexp = /\A([\w\.%\+\-]+)@uke\.gov\.pl\z/i

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  # config.timeout_in = 30.minutes

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  # config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [:email]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  # config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  # config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # Warn on the last attempt before the account is locked.
  # config.last_attempt_warning = true

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [:email]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 6.hours

  # When set to false, does not sign a user in automatically after their password is
  # reset. Defaults to true, so a user is signed in automatically after a reset.
  # config.sign_in_after_reset_password = true

  # ==> Configuration for :encryptable
  # Allow you to use another hashing or encryption algorithm besides bcrypt (default).
  # You can use :sha1, :sha512 or algorithms from others authentication tools as
  # :clearance_sha1, :authlogic_sha512 (then you should set stretches above to 20
  # for default behavior) and :restful_authentication_sha1 (then you should set
  # stretches to 10, and copy REST_AUTH_SITE_KEY to pepper).
  #
  # Require the `devise-encryptable` gem when using anything other than bcrypt
  # config.encryptor = :sha512

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = false

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  # config.navigational_formats = ['*/*', :html]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user,public_repo'

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  # config.warden do |manager|
  #   manager.intercept_401 = false
  #   manager.default_strategies(scope: :user).unshift :some_external_strategy
  # end

  # ==> Mountable engine configurations
  # When using Devise inside an engine, let's call it `MyEngine`, and this engine
  # is mountable, there are some extra configurations to be taken into account.
  # The following options are available, assuming the engine is mounted as:
  #
  #     mount MyEngine, at: '/my_engine'
  #
  # The router that invoked `devise_for`, in the example above, would be:
  # config.router_name = :my_engine
  #
  # When using OmniAuth, Devise cannot automatically set OmniAuth path,
  # so you need to do it manually. For the users scope, it would be:
  # config.omniauth_path_prefix = '/my_engine/users/auth'

# ==> Configuration for :saml_authenticatable

  # Create user if the user does not exist. (Default is false)
  config.saml_create_user = true

  # Update the attributes of the user after a successful login. (Default is false)
  config.saml_update_user = true

  # Set the default user key. The user will be looked up by this key. Make
  # sure that the Authentication Response includes the attribute.
  config.saml_default_user_key = :email

  # Optional. This stores the session index defined by the IDP during login.  If provided it will be used as a salt
  # for the user's session to facilitate an IDP initiated logout request.
  config.saml_session_index_key = :session_index

  # You can set this value to use Subject or SAML assertation as info to which email will be compared.
  # If you don't set it then email will be extracted from SAML assertation attributes.
  #
  # CHECK THIS AGAINST SAML response
  #
  config.saml_use_subject = true

  # You can support multiple IdPs by setting this value to a class that implements a #settings method which takes
  # an IdP entity id as an argument and returns a hash of idp settings for the corresponding IdP.
  config.idp_settings_adapter = nil

  # You provide you own method to find the idp_entity_id in a SAML message in the case of multiple IdPs
  # by setting this to a custom reader class, or use the default.
  # config.idp_entity_id_reader = DeviseSamlAuthenticatable::DefaultIdpEntityIdReader

  # You can set a handler object that takes the response for a failed SAML request and the strategy,
  # and implements a #handle method. This method can then redirect the user, return error messages, etc.
  # config.saml_failed_callback = nil

  config.saml_configure do |settings|
    settings.assertion_consumer_service_url     = "#{Rails.application.secrets[:idp_callback_to]}/users/saml/auth"
    settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
    settings.name_identifier_format             = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
    #settings.issuer                             = "http://localhost:3000/users/saml/metadata"
    settings.issuer                             = "#{Rails.application.secrets[:idp_issuer]}"
    settings.authn_context                      = ""
    #settings.idp_entity_id                      = "sso.dev.com"
    #settings.idp_entity_id                      = "localhost"
# orygial    settings.authn_context              = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    settings.idp_sso_target_url                 = "#{Rails.application.secrets[:idp_target_url]}/samlsso"
    #settings.idp_slo_target_url                 = "https://localhost:9443/samlsso?slo=true"
    #settings.idp_slo_target_url                 = "https://localhost:9443/samlsso?slo=true&spEntityID=http://localhost:3000/users/saml/metadata"
    #settings.idp_slo_target_url                 = "https://localhost:9443/samlsso?slo=true&spEntityID=http://localhost:3000/users/saml/metadata&returnTo=http://localhost:3000"
    settings.idp_slo_target_url                 = "#{Rails.application.secrets[:idp_target_url]}/samlsso?slo=true&spEntityID=#{Rails.application.secrets[:idp_issuer]}&returnTo=#{Rails.application.secrets[:idp_callback_to]}"

#settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
#settings.assertion_consumer_logout_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
    #settings.idp_cert                           = ENV["IDP_CERT"]

    #settings.idp_cert_fingerprint               = ENV["IDP_CERT_FINGERPRINT"]
    settings.idp_cert_fingerprint               = "#{Rails.application.secrets[:idp_cert_fingerprint]}"
    settings.idp_cert_fingerprint_algorithm     = "#{Rails.application.secrets[:idp_cert_fingerprint_algorithm]}"
    #settings.idp_cert_fingerprint_algorithm = "http://www.w3.org/2000/09/xmldsig#sha256"
    # Certificate in WSO2IS fingerprints:
    #    SHA1: DC:0D:70:68:BA:E9:EA:86:37:1C:BE:86:69:64:BF:87:3B:A7:0A:47
    #### ~$export IDP_CERT_FINGERPRINT="DC:0D:70:68:BA:E9:EA:86:37:1C:BE:86:69:64:BF:87:3B:A7:0A:47"
    #    SHA256: C7:33:8E:FA:44:6A:3F:63:7D:08:94:D9:91:FF:78:53:DB:BE:DC:73:72:3A:A1:31:F0:AC:60:E3:1F:77:90:2E
    # ??? chyba nadpisuje konfigurację w WSO2IS, gdyż wystarczy prawidłowa para parametrów:
    # settings.idp_cert_fingerprint oraz settings.idp_cert_fingerprint_algorithm i działa.

    # Security section
    # settings.soft = true
    # settings.security[:authn_requests_signed] = true
    # settings.security[:logout_requests_signed] = false
    # settings.security[:logout_responses_signed] = false
    # settings.security[:metadata_signed] = false
    # settings.security[:digest_method] = XMLSecurity::Document::SHA256
    # settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256

  end

end

# http://xacmlinfo.org/2017/08/03/how-to-renew-self-signed-certificate-keeping-old-private-key/

# build
# openssl genrsa -out idp.pem 2048
# openssl req -new -x509 -sha256 -key idp.pem -out idp.crt -days 365


#openssl x509 -inform der -in xxx.crt -out xxx.pem

# display
# openssl x509 -text -noout -in /home/bjarzab/www/registration/idp.crt  -fingerprint -sha256

# Current localhost 
# Certificate fingerprints:
#    SHA1: DC:0D:70:68:BA:E9:EA:86:37:1C:BE:86:69:64:BF:87:3B:A7:0A:47
#    SHA256: C7:33:8E:FA:44:6A:3F:63:7D:08:94:D9:91:FF:78:53:DB:BE:DC:73:72:3A:A1:31:F0:AC:60:E3:1F:77:90:2E


# http://xacmlinfo.org/2017/08/03/how-to-renew-self-signed-certificate-keeping-old-private-key/

# build
# openssl genrsa -out idp.pem 2048
# openssl req -new -x509 -sha256 -key idp.pem -out idp.crt -days 365


#openssl x509 -inform der -in xxx.crt -out xxx.pem

# display
# openssl x509 -text -noout -in /home/bjarzab/www/registration/idp.crt  -fingerprint -sha256

# Current wso2is 
# Certificate fingerprints:
#    SHA1: DC:0D:70:68:BA:E9:EA:86:37:1C:BE:86:69:64:BF:87:3B:A7:0A:47
#    SHA256: C7:33:8E:FA:44:6A:3F:63:7D:08:94:D9:91:FF:78:53:DB:BE:DC:73:72:3A:A1:31:F0:AC:60:E3:1F:77:90:2E
