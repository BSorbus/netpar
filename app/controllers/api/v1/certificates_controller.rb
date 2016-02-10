class Api::V1::CertificatesController < Api::V1::BaseApiController
  #before_action :authenticate_user!
  before_action :authenticate_with_token!#, only: [:update, :destroy]

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
    render status: :ok,
           json: certificate, include: [:division] 
  end

  def lot
    authorize :certificate, :index_l?

    certificates = Certificate.where(category: "L").limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
    render status: :ok,
           json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
  end

  def mor
    authorize :certificate, :index_m?

    certificates = Certificate.where(category: "M").limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
    render status: :ok,
           json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
  end

  def ra
    authorize :certificate, :index_r?

    certificates = Certificate.where(category: "R").limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
    render status: :ok,
           json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
  end

  def search_by_number
    authorize :certificate, :index?

    if params[:number].blank?
      render status: :not_acceptable,
             json: { error: 406, message: "No params[:number]" }
    else
      certificates = Certificate.where(number: params[:number].upcase).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
      if certificates.present?
        render status: :ok,
           json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
      else
        render status: :not_found,
               json: { error: 404, message: "No record for Certificate[:number] = #{params[:number].upcase}" }

      end
    end
  end

  def search_by_customer_pesel
    authorize :certificate, :index?

    if params[:pesel].blank?
      render status: :not_acceptable,
             json: { error: 406, message: "No params[:pesel]" }
    else
      certificates = Certificate.joins(:customer).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).where(customers: {pesel: params[:pesel]})
      if certificates.present?
        render status: :ok,
               json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
      else
        render status: :not_found,
               json: { error: 404, message: "No record for Customer[:pesel] = #{params[:pesel]}" }

      end
    end
  end

end