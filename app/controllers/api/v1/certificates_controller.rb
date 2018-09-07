class Api::V1::CertificatesController < Api::V1::BaseApiController
  before_action :authenticate_with_token!#, only: [:update, :destroy]

  respond_to :json


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

  def lot_search_by_number
    authorize :certificate, :index_l?

    if params[:number].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:number]" }
    else
      certificates = Certificate.where(category: "L", number: params[:number].upcase).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
      if certificates.present?
        render status: :ok,
           json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Certificate.where(category: 'L', number: '#{params[:number].upcase}')" }

      end
    end
  end

  def mor_search_by_number
    authorize :certificate, :index_m?

    if params[:number].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:number]" }
    else
      certificates = Certificate.where(category: "M", number: params[:number].upcase).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
      if certificates.present?
        render status: :ok,
           json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Certificate.where(category: 'M', number: '#{params[:number].upcase}')" }

      end
    end
  end

  def ra_search_by_number
    authorize :certificate, :index_r?

    if params[:number].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:number]" }
    else
      certificates = Certificate.where(category: "R", number: params[:number].upcase).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
      if certificates.present?
        render status: :ok,
           json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Certificate.where(category: 'R', number: '#{params[:number].upcase}')" }

      end
    end
  end

  def all_search_by_number
    authorize :certificate, :index?

    if params[:number].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:number]" }
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
               json: { error: "Brak rekordów dla Certificate.where(number: '#{params[:number].upcase}')" }

      end
    end
  end

  def lot_search_by_customer_pesel
    authorize :certificate, :index_l?

    if params[:pesel].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:pesel]" }
    else
      certificates = Certificate.joins(:customer).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).where(category: "L", customers: {pesel: params[:pesel]})
      if certificates.present?
        render status: :ok,
               json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Certificate.where(category: 'L') AND Customer.where(pesel: '#{params[:pesel]}')" }

      end
    end
  end

  def mor_search_by_customer_pesel
    authorize :certificate, :index_m?

    if params[:pesel].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:pesel]" }
    else
      certificates = Certificate.joins(:customer).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).where(category: "M", customers: {pesel: params[:pesel]})
      if certificates.present?
        render status: :ok,
               json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Certificate.where(category: 'M') AND Customer.where(pesel: '#{params[:pesel]}')" }

      end
    end
  end

  def ra_search_by_customer_pesel
    authorize :certificate, :index_r?

    if params[:pesel].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:pesel]" }
    else
      certificates = Certificate.joins(:customer).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).where(category: "R", customers: {pesel: params[:pesel]})
      if certificates.present?
        render status: :ok,
               json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Certificate.where(category: 'R') AND Customer.where(pesel: '#{params[:pesel]}')" }

      end
    end
  end

  def all_search_by_customer_pesel
    authorize :certificate, :index?

    if params[:pesel].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:pesel]" }
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
               json: { error: "Brak rekordów dla Customer.where(pesel: '#{params[:pesel]}')" }

      end
    end
  end

  def mor_search_by_multi_params
    authorize :certificate, :index_m?
    #vialid_thru = vialid_thru.blank? ? nil : vialid_thru 

    if params[:number].blank? || params[:date_of_issue].blank? || params[:name].blank? || params[:given_names].blank?
      render status: :not_acceptable,
             json: { error: "Brak wszystkich parametrów / All parameters are missing" }
    else
      certificates = Certificate.joins(:customer).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
        .where(category: 'M', number: "#{params[:number]}", customers: {birth_date: "#{params[:birth_date}"})
        .where("UPPER(unaccent(customers.name)) = UPPER(unaccent('#{params[:name]}')) AND
                UPPER(unaccent(customers.given_names)) = UPPER(unaccent('#{params[:given_names]}'))")

      #works = certificate.first.works if certificate.present? 
      if certificates.present?
        render status: :ok,
               json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
      else
        render status: :not_found,
               json: { error: "Brak danych / No data" }
      end
    end
  end


end
