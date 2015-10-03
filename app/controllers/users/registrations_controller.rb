class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  def destroy  
    resource.soft_delete
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)  
    set_flash_message :notice, :destroyed if is_flashing_format?  
    yield resource if block_given?  
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }  
  end  

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected


  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end


  # If the account that is registered is confirmable and not active yet, 
  # you have to override after_inactive_sign_up_path_for method.
  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    Work.create!(trackable: resource, trackable_url: "#{user_path(resource)}", action: :sign_up, user: resource, 
      parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: resource.id, name: resource.name, email: resource.email, notice: request.flash["notice"]})
    super(resource)
  end
end
