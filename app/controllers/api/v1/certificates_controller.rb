module Api
  module V1
    class CertificatesController < BaseApiController
      before_action :authenticate_user!

      respond_to :json


      #def index
      #  #authenticate_user!
      #  #@certificate = Certificate.all page: params[:page] per_page: params[:per_page]
      #  #@certificate = Certificate.page(7).per(10)
      #  certificate = Certificate.where(category: params[:category_service].upcase).page(1).per(5)
      #  render json: certificate, meta: { pagination:
      #                             { per_page: params[:per_page],
      #                               total_pages: certificate.total_pages,
      #                               total_objects: certificate.total_count } }
      #end
      def show
        #authenticate_user!
        certificate = Certificate.find_by(id: params[:id])
        render status: 200,
               json: certificate, include: [:division] 
      end

      def lot
        certificates = Certificate.where(category: "L").limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
        render status: 200,
               json: certificates, meta: { collection:
                                   { offset: params[:offset] ||= 0,
                                     limit: params[:limit] ||= 10,
                                     objects: certificates.size } }
      end

      def mor
        certificates = Certificate.where(category: "M").limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
        render status: 200,
               json: certificates, meta: { collection:
                                   { offset: params[:offset] ||= 0,
                                     limit: params[:limit] ||= 10,
                                     objects: certificates.size } }
      end

      def ra
        certificates = Certificate.where(category: "R").limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
        render status: 200,
               json: certificates, meta: { collection:
                                   { offset: params[:offset] ||= 0,
                                     limit: params[:limit] ||= 10,
                                     objects: certificates.size } }
      end

      def search_by_number
        if params[:number].blank?
          render status: :not_acceptable,
                 json: { error: 406,
                            message: "No params[:number]" }
        else
          certificates = Certificate.where(number: params[:number].upcase).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
          if certificates.present?
            render status: 200,
               json: certificates, meta: { collection:
                                   { offset: params[:offset] ||= 0,
                                     limit: params[:limit] ||= 10,
                                     objects: certificates.size } }
          else
            render status: :not_found,
                   json: { error: 404,
                              message: "No record for Certificate[:number] = #{params[:number].upcase}" }

          end
        end
      end

      def search_by_customer_pesel
        if params[:pesel].blank?
          render status: :not_acceptable,
                 json: { error: 406,
                            message: "No params[:pesel]" }
        else
          certificates = Certificate.joins(:customer).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).where(customers: {pesel: params[:pesel]})
          if certificates.present?
            render status: 200,
                   json: certificates, meta: { collection:
                                   { offset: params[:offset] ||= 0,
                                     limit: params[:limit] ||= 10,
                                     objects: certificates.size } }
          else
            render status: :not_found,
                   json: { error: 404,
                              message: "No record for Customer[:pesel] = #{params[:pesel]}" }

          end
        end
      end

    end
  end
end