module Api
  module V1
    module Authenticable

      # Devise methods overwrites
      def current_user
        @current_user ||= User.find_by(authentication_token: request.headers['Authorization'])
      end

      def authenticate_with_token!
        render json: { errors: t("devise.failure.unauthenticated") },
                    status: :unauthorized unless current_user.present?
      end

      def user_signed_in?
        current_user.present?
      end

    end
  end
end