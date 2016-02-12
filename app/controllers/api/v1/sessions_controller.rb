class Api::V1::SessionsController < Api::V1::BaseApiController
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  skip_before_filter :verify_signed_out_user

  respond_to :json

#    secret_key = Rails.application.secrets[:secret_key_base]
#    salt = Digest::MD5.hexdigest(secret_key)
#    #password = "2wsxcdE#"
#    Digest::SHA512.hexdigest(salt+pass)


  def create
    user_password = params[:session][:password]
    user_email = params[:session][:email]
    user = user_email.present? && User.find_by(email: user_email)

    if user.present? && user.valid_password?(user_password)
      if user.expired?
        render status: :unauthorized,
               json: { error: t('devise.failure.expired') }        
      else     
        if user.need_change_password?
          render status: :unauthorized,
                 json: { error: t('devise.password_expired.change_required_api') }
        else
          sign_in user, store: false
          user.generate_authentication_token!
          user.save
          render status: :ok, 
                 json: user 

          Work.create!(trackable: user, trackable_url: "#{user_path(user)}", action: :sign_in_from_api, user: user, 
            parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: user.id, name: user.name, 
                         email: user.email, notice: request.flash["notice"]}.to_json)
        end
      end
    else
      render status: :unprocessable_entity,
             json: { error: t('devise.failure.invalid') }

      Work.create( action: :unauthenticated, user_id: nil, parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, email: user_email} )
    end


    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    #if user && Devise.secure_compare(user.authentication_token, params[:user_token])
    #  sign_in user, store: false
    #end
 end

  def destroy
    user = User.find_by(authentication_token: params[:id])
    user.generate_authentication_token!
    user.save
    head 204
  end

end