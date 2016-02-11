class Users::SessionsController < Devise::SessionsController

  # respond_to :json
  # dodanie powyższego umożliwia zalogowanie się z cUrla
  # curl -v -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST $ROOT_URL/users/sign_in -d '{"user":{"email":"a.wojcieszek@uke.gov.pl","password":"1qazXSW@"}}'

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    # Jeżeli udane logowanie, to zapisz do historii
    Work.create!(trackable: current_user, trackable_url: "#{user_path(current_user)}", action: :sign_in, user: current_user, 
      parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: current_user.id, name: current_user.name, email: current_user.email, notice: request.flash["notice"]}.to_json)
  end

  # DELETE /resource/sign_out
  def destroy
    u = current_user
    super
    # Jeżeli udane wylogowanie, to zapisz do historii
    Work.create!(trackable: u, trackable_url: "#{user_path(u)}", action: :sign_out, user: u, parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: u.id, name: u.name, email: u.email, notice: request.flash["notice"]}.to_json)
  end


  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
