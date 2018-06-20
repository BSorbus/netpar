module Api
  module V1
    module Authenticable

      # Devise methods overwrites
      def current_user
        @current_user ||= User.find_by(authentication_token: request.headers['Authorization']) if request.headers['Authorization'].present?
      end

      def authenticate_with_token!
        if current_user.present?
          if current_user.last_activity_at + Rails.application.secrets.api_token_expire.seconds < Time.now
            render status: :unauthorized, 
                   json: { errors: t("devise.failure.timeout") }
          else
            current_user.update_attributes(last_activity_at: Time.now)
          end         
        else
          render status: :unauthorized, 
                 json: { errors: t("devise.failure.unauthenticated") }
        end
      end

      def user_signed_in?
        current_user.present?
      end


    end
  end
end