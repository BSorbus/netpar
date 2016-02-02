module Api
  module V1
    class CertificatesController < ApplicationController
      acts_as_token_authentication_handler_for User, fallback_to_devise: false

      before_action :authenticate_user!

      respond_to :json

      #before_filter :verify_token


  swagger_controller :certificates, "Index and Show certificate", resource_path: "/certificates"
 
  swagger_api :index do
    summary "Index"
    response :unauthorized
    response :not_acceptable
  end
  swagger_api :show do
    summary "Show"
    param :path, :id, :integer, :required, "Certificate ID"
    response :unauthorized
    response :not_acceptable
  end
      def index
        #authenticate_user!
        #@certificate = Certificate.all page: params[:page] per_page: params[:per_page]
        #@certificate = Certificate.page(7).per(10)
        certificate = Certificate.page(1).per(5)
        render json: certificate, meta: { pagination:
                                   { per_page: params[:per_page],
                                     total_pages: certificate.total_pages,
                                     total_objects: certificate.total_count } }
      end
      def show
        #authenticate_user!
        @certificate = Certificate.find_by(id: params[:id])
        render json: @certificate, include: [:division] 
      end
    end
  end
end