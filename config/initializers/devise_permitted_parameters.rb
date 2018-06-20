module DevisePermittedParameters
  extend ActiveSupport::Concern

  included do
    before_filter :configure_permitted_parameters
  end

  protected

#  def configure_permitted_parameters
#    devise_parameter_sanitizer.for(:sign_up) << :name
#    devise_parameter_sanitizer.for(:account_update) << :name
#  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :esod_password, :password, :password_confirmation, :current_password) }
  end



end

DeviseController.send :include, DevisePermittedParameters
