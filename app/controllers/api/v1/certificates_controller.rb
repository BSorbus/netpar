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

    requ_json = { "number_prefix": "#{params[:number_prefix]}", 
                  "number": "#{params[:number]}",
                  "date_of_issue": "#{params[:date_of_issue]}",
                  "valid_thru": "#{params[:valid_thru]}",
                  "name": "#{params[:name]}",
                  "given_names": "#{params[:given_names]}",
                  "birth_date": "#{params[:birth_date]}" }

    if params[:number_prefix].blank? || params[:number].blank? || params[:date_of_issue].blank? || params[:name].blank? || params[:given_names].blank? || params[:birth_date].blank? || (params[:valid_thru].blank? && ! ['GL-', 'GS-', 'MA-', 'GS-', 'GC-', 'IW-'].include?(params[:number_prefix]))
      resp_json = { error: "Brak wszystkich parametrów / All parameters are missing" }
      render status: :not_acceptable,
             json: resp_json
    else
      req_number = ActionController::Base.helpers.sanitize("#{params[:number_prefix]}"+"#{params[:number]}")
      req_date_of_issue = ActionController::Base.helpers.sanitize(params[:date_of_issue])
      req_valid_thru = ActionController::Base.helpers.sanitize(params[:valid_thru])
      req_name = ActionController::Base.helpers.sanitize(params[:name])
      req_given_names = ActionController::Base.helpers.sanitize(params[:given_names]) 
      req_birth_date = ActionController::Base.helpers.sanitize(params[:birth_date])

      certificates = Certificate.joins(:customer).limit(1).offset(0)
        .where(canceled: false, category: 'M', number: "#{req_number}", customers: {birth_date: "#{req_birth_date}"})
        .where("UPPER(unaccent(customers.name)) = UPPER(unaccent('#{req_name}')) AND
                UPPER(unaccent(customers.given_names)) = UPPER(unaccent('#{req_given_names}'))")

      works = certificates.first.works if certificates.present?
      equal_data = nil
      if works.present?
        works.each do |rec|
          if JSON.parse(rec.parameters)['date_of_issue'] == req_date_of_issue 
            if params[:valid_thru].present?
              equal_data = rec if JSON.parse(rec.parameters)['valid_thru'] == req_valid_thru
            else
              equal_data = rec
            end
          end
        end
      end

      if equal_data.present?
        division = Division.find("#{JSON.parse(equal_data.parameters)['division']['id']}")
        resp_json = {
                      "certificates": [
                        {
                          "id": "#{JSON.parse(equal_data.parameters)['id']}",
                          "number": "#{JSON.parse(equal_data.parameters)['number']}",
                          "date_of_issue": "#{JSON.parse(equal_data.parameters)['date_of_issue']}",
                          "valid_thru": "#{JSON.parse(equal_data.parameters)['valid_thru']}",
                          "category": "#{JSON.parse(equal_data.parameters)['category']}",
                          "division": {
                            "id": "#{JSON.parse(equal_data.parameters)['division']['id']}",
                            "name": division.name,
                            "english_name": division.english_name,
                            "short_name": division.short_name,
                            "number_prefix": division.number_prefix
                          },
                          "customer": {
                            "id": "#{JSON.parse(equal_data.parameters)['customer']['id']}",
                            "name": "#{JSON.parse(equal_data.parameters)['customer']['name']}",
                            "given_names": "#{JSON.parse(equal_data.parameters)['customer']['given_names']}",
                            "birth_date": "#{JSON.parse(equal_data.parameters)['customer']['birth_date']}",
                          }
                        }
                      ],
                      "meta": {
                        "collection": {
                          "offset": 0,
                          "limit": 1,
                          "objects": 1
                        }
                      }
                    }

        render status: :ok,
               json: resp_json
      else
        resp_json = { error: "Brak danych / No data" }
        render status: :not_found,
               json: resp_json
      end

    end

    ConfirmationLog.create!(remote_ip: "#{request.headers['X-Real-IP']}", request_json: "#{requ_json}", response_json: "#{resp_json}")

  end


end
