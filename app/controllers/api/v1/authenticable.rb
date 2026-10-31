module Api
  module V1
    module Authenticable

      # Bez danych logowania – 401 (dawniej błąd 500); hasło porównywane w stałym czasie.
      def token
        system_for_api = authenticate_with_http_basic do |username, password|
          api_key = ApiKey.find_by(name: username)
          api_key if api_key && ActiveSupport::SecurityUtils.secure_compare(api_key.password.to_s, password.to_s)
        end
        if system_for_api
          render json: { token: system_for_api.access_token }, status: 200
        else
          render json: { error: 'Incorrect credentials' }, status: 401
        end
      end

      def authenticate_system_from_token
        unless authenticate_with_http_token { |token, options| ApiKey.find_by(access_token: token) }
          render json: { error: 'Bad Token'}, status: 401
        end
      end

    end
  end
end