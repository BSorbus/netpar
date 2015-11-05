class MyMailer < Devise::Mailer
  #helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  default from: Rails.application.secrets.email_provider_username
  default cc: Rails.application.secrets.email_provider_username

  # Overrides same inside Devise::Mailer
  def confirmation_instructions(record, token, opts={})
    #set_organization_of record

    @url  = Rails.application.secrets.domain_name
    #attachments.inline['logo.png'] = File.read("app/assets/images/logo.png")
    attachments.inline['logo.jpg'] = File.read("app/assets/images/netpar2015.jpg")
    #!!!!!!!!!!!!!!!!!!!!!!
    #opts[:to] = 'BSorbus@gmail.com'   
    #opts[:subject] = "NetPAR 2015 - Instrukcja aktywowania konta"
    super
  end

  # Overrides same inside Devise::Mailer
  def reset_password_instructions(record, token, opts={})
    @url  = Rails.application.secrets.domain_name
    attachments.inline['logo.jpg'] = File.read("app/assets/images/netpar2015.jpg")
    super
  end

  # Overrides same inside Devise::Mailer
  def unlock_instructions(record, token, opts={})
    @url  = Rails.application.secrets.domain_name
    attachments.inline['logo.jpg'] = File.read("app/assets/images/netpar2015.jpg")
    super
  end

  private
  ##
  # Sets organization of the user if available
  def set_organization_of(user)
    #@organization = user.organization rescue nil
  end
end

