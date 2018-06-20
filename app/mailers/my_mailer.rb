class MyMailer < Devise::Mailer
  #helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  default from: Rails.application.secrets.email_provider_username
  default cc: Rails.application.secrets.email_provider_username

  # Overrides same inside Devise::Mailer
  def confirmation_instructions(record, token, opts={})
    @url  = Rails.application.secrets.domain_name
    attachments.inline['logo.jpg'] = File.read("app/assets/images/netpar2015.png")
    # !!!!!!!!!!!!!!!!!!!!!!
    # opts[:to] = 'BSorbus@gmail.com'   
    # opts[:subject] = "NetPAR 2015 - Instrukcja aktywowania konta"

    # Use different e-mail templates for signup e-mail confirmation and for when a user changes e-mail address.
    if record.pending_reconfirmation?
      opts[:template_name] = 'reconfirmation_instructions'
    else
      opts[:template_name] = 'confirmation_instructions'
    end
    super
  end

  # Overrides same inside Devise::Mailer
  def reset_password_instructions(record, token, opts={})
    @url  = Rails.application.secrets.domain_name
    attachments.inline['logo.jpg'] = File.read("app/assets/images/netpar2015.png")
    super
  end

  # Overrides same inside Devise::Mailer
  def unlock_instructions(record, token, opts={})
    @url  = Rails.application.secrets.domain_name
    attachments.inline['logo.jpg'] = File.read("app/assets/images/netpar2015.png")
    super
  end

  private
  ##
  # Sets organization of the user if available
  def set_organization_of(user)
    #@organization = user.organization rescue nil
  end
end

