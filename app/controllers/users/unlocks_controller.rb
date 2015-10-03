class Users::UnlocksController < Devise::UnlocksController
  # GET /resource/unlock/new
  # def new
  #   super
  # end

  # POST /resource/unlock
  # def create
  #   super
  # end

  # GET /resource/unlock?unlock_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after sending unlock password instructions
  def after_sending_unlock_instructions_path_for(resource)
    Work.create!(trackable: resource, trackable_url: "#{user_path(resource)}", action: :sending_unlock_instructions, user: resource, 
      parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: resource.id, name: resource.name, email: resource.email, notice: request.flash["notice"]})
    super(resource)
  end

  # The path used after unlocking the resource
  def after_unlock_path_for(resource)
    Work.create!(trackable: resource, trackable_url: "#{user_path(resource)}", action: :unlocking_from_token, user: resource, 
      parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: resource.id, name: resource.name, email: resource.email, notice: request.flash["notice"]})
    super(resource)
  end
end
