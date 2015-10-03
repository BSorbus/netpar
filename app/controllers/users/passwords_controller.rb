class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  def after_resetting_password_path_for(resource)
    Work.create!(trackable: resource, trackable_url: "#{user_path(resource)}", action: :resetting_password_from_token, user: resource, 
      parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: resource.id, name: resource.name, email: resource.email, notice: request.flash["notice"]})
    super(resource)
  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    Work.create!(trackable: resource, trackable_url: "#{user_path(resource)}", action: :sending_reset_password_instructions, user: resource, 
      parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: resource.id, name: resource.name, email: resource.email, notice: request.flash["notice"]})
    super(resource_name)
  end
end
