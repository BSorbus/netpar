class Api::V1::CertificatesController < Api::V1::BaseApiController

  respond_to :json


  def show
    #authenticate_user!
    certificate = Certificate.find_by(id: params[:id])
    render status: :ok,
           json: certificate, include: [:division] 
  end

  def lot
    # authorize :certificate, :index_l?

    certificates = Certificate.where(category: "L").limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
    render status: :ok,
           json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
  end

  def mor
    # authorize :certificate, :index_m?

    certificates = Certificate.where(category: "M").limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
    render status: :ok,
           json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
  end

  def ra
    # authorize :certificate, :index_r?

    certificates = Certificate.where(category: "R").limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
    render status: :ok,
           json: certificates, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: certificates.size } }
  end

  def mor_search_by_multi_params
    # authorize :certificate, :index_m?

    requ_json = { "number_prefix": "#{params[:number_prefix]}", 
                  "number": "#{params[:number]}",
                  "date_of_issue": "#{params[:date_of_issue]}",
                  "valid_thru": "#{params[:valid_thru]}",
                  "name": "#{params[:name]}",
                  "given_names": "#{params[:given_names]}",
                  "birth_date": "#{params[:birth_date]}" }

    if params[:number_prefix].blank? || params[:number].blank? || params[:date_of_issue].blank? || params[:name].blank? || params[:given_names].blank? || params[:birth_date].blank? || (params[:valid_thru].blank? && ! ['GL-', 'GS-', 'MA-', 'GS-', 'GC-', 'IW-'].include?(params[:number_prefix]))
      render_not_params
    else
      req_number = ActionController::Base.helpers.sanitize("#{params[:number_prefix]}"+"#{params[:number]}")
      req_date_of_issue = ActionController::Base.helpers.sanitize(params[:date_of_issue])
      req_valid_thru = ActionController::Base.helpers.sanitize(params[:valid_thru])
      req_name = ActionController::Base.helpers.sanitize(params[:name])
      req_given_names = ActionController::Base.helpers.sanitize(params[:given_names]) 
      req_birth_date = ActionController::Base.helpers.sanitize(params[:birth_date])

      certificate = Certificate.find_by("certificates.canceled = false AND certificates.category = 'M' AND TRIM(certificates.number) = '#{req_number}'")

      if certificate.blank?
        render_not_found(requ_json)
      else
        resp_json = campare_data(req_number, req_date_of_issue, req_valid_thru, req_name, req_given_names, req_birth_date, certificate )
        resp_json.blank? ? render_not_found(requ_json) : render_data_is_equal(requ_json, resp_json) 
      end
    end
  end

  private

    def render_not_params
      render status: :not_acceptable, json: { error: "Brak wszystkich parametrów / All parameters are missing" }
    end

    def render_not_found(requ_json)
      resp_json = { error: "Brak danych / No data" }
      ConfirmationLog.create!(remote_ip: "#{request.headers['X-Real-IP']}", request_json: "#{requ_json}", response_json: "#{resp_json}")
      render status: :not_found, json: resp_json
    end

    def render_data_is_equal(requ_json, resp_json)
      ConfirmationLog.create!(remote_ip: "#{request.headers['X-Real-IP']}", request_json: "#{requ_json}", response_json: "#{resp_json}")
      render status: :ok, json: resp_json
    end

    def campare_data(number, date_of_issue, valid_thru, name, given_names, birth_date, certificate_record)
      resp_json = campare_data_basic(number, date_of_issue, valid_thru, name, given_names, birth_date, certificate_record)
      resp_json = campare_data_with_history(number, date_of_issue, valid_thru, name, given_names, birth_date, certificate_record) if resp_json.blank?
      
      return resp_json
    end

    def campare_data_basic(number, date_of_issue, valid_thru, name, given_names, birth_date, certificate_record)
      if  certificate_record.number.strip == number.strip && 
          certificate_record.date_of_issue.to_s == date_of_issue.to_s && 
          certificate_record.valid_thru.to_s == valid_thru.to_s &&
            I18n.transliterate(certificate_record.customer.name).upcase.strip == I18n.transliterate(name).upcase.strip &&
            I18n.transliterate(certificate_record.customer.given_names).upcase.strip == I18n.transliterate(given_names).upcase.strip &&
            certificate_record.customer.birth_date.to_s == birth_date.to_s

        return  {
                  "certificates": [
                    {
                      "id": certificate_record.id,
                      "number": number,
                      "date_of_issue": date_of_issue,
                      "valid_thru": valid_thru,
                      "category": certificate_record.category,
                      "division": {
                        "id": certificate_record.division_id,
                        "name": certificate_record.division.name,
                        "english_name": certificate_record.division.english_name,
                        "short_name": certificate_record.division.short_name,
                        "number_prefix": certificate_record.division.number_prefix
                      },
                      "customer": {
                        "id": certificate_record.customer_id,
                        "name": name,
                        "given_names": given_names,
                        "birth_date": birth_date
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

      end
    end

    def campare_data_with_history(number, date_of_issue, valid_thru, name, given_names, birth_date, certificate_record)
      resp_json = nil
      certificate_record.works.where(action: [:create, :update]).each do |history_record|
        resp_json = campare_data_with_history_row(number, date_of_issue, valid_thru, name, given_names, birth_date, certificate_record, history_record)
        break if resp_json.present?
      end

      return resp_json
    end

    def campare_data_with_history_row(number, date_of_issue, valid_thru, name, given_names, birth_date, certificate_record, history_record)
      if JSON.parse(history_record.parameters)['number'].present? &&
         JSON.parse(history_record.parameters)['date_of_issue'].present? &&
         JSON.parse(history_record.parameters)['valid_thru'].present? && 
         JSON.parse(history_record.parameters)['customer'].present?

        if JSON.parse(history_record.parameters)['customer']['name'].present? &&
           JSON.parse(history_record.parameters)['customer']['given_names'].present? &&
           JSON.parse(history_record.parameters)['customer']['birth_date'].present?

          if JSON.parse(history_record.parameters)['number'].strip == number.strip &&
             JSON.parse(history_record.parameters)['date_of_issue'] == date_of_issue &&
             JSON.parse(history_record.parameters)['valid_thru'] == valid_thru &&
             I18n.transliterate(JSON.parse(history_record.parameters)['customer']['name']).upcase.strip == I18n.transliterate(name).upcase.strip &&
             I18n.transliterate(JSON.parse(history_record.parameters)['customer']['given_names']).upcase.strip == I18n.transliterate(given_names).upcase.strip &&
             JSON.parse(history_record.parameters)['customer']['birth_date'] == birth_date

            return  {
                      "certificates": [
                        {
                          "id": JSON.parse(history_record.parameters)['id'],
                          "number": number,
                          "date_of_issue": date_of_issue,
                          "valid_thru": valid_thru,
                          "category": certificate_record.category,
                          "division": {
                            "id": certificate_record.division_id,
                            "name": certificate_record.division.name,
                            "english_name": certificate_record.division.english_name,
                            "short_name": certificate_record.division.short_name,
                            "number_prefix": certificate_record.division.number_prefix
                          },
                          "customer": {
                            "id": JSON.parse(history_record.parameters)['customer']['id'],
                            "name": JSON.parse(history_record.parameters)['customer']['name'],
                            "given_names": JSON.parse(history_record.parameters)['customer']['given_names'],
                            "birth_date": JSON.parse(history_record.parameters)['customer']['birth_date']
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

          end 
        end
      end
    end


end
