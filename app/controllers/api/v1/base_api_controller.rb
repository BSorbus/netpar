module Api
  module V1
    class BaseApiController < ApplicationController

      include Authenticable

      protect_from_forgery with: :null_session

      before_action :destroy_session
      before_action :restricted_area

      def destroy_session
        request.session_options[:skip] = true
      end


      # override from ApplicationController
      def restricted_area
        unless request_from_the_security_area?
          render status: :forbidden, json: {error: 403, message: t("restricted_area") } and return
        end
      end 


    end
  end
end