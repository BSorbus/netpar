# API weryfikacji świadectw (token, każda odpowiedź poza 406 – wpis w ConfirmationLog):
# - mor_search_by_multi_params – STARE confirmation (tylko świadectwa morskie; do usunięcia razem ze starym confirmation);
# - search – confirmation8: weryfikacja po danych z formularza (L, M, R), porównanie z bieżącym świadectwem i historią zmian;
# - search_by_code – confirmation8: weryfikacja po kodzie świadectwa (QR karty i zaświadczenia: <confirmation>/qrc/<kod>).
# search i search_by_code: ten sam format odpowiedzi; 403 – rodzaj wyłączony z weryfikacji internetowej
# (divisions.enabled_in_confirmation), w search dopiero po pełnym dopasowaniu danych (po samym numerze nie da się wykryć
# istnienia świadectwa); verification_url – adres do kodu QR zaświadczenia (Certificate#qr_code_url).
# Akcje show, lot, mor, ra usunięte 2026-11 (nieużywane wg logów produkcji z roku).
class Api::V1::CertificatesController < Api::V1::BaseApiController

  CATEGORIES = %w(L M R)

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

      certificate = Certificate.where(canceled: false, category: 'M').find_by("TRIM(certificates.number) = ?", req_number)

      if certificate.blank?
        render_not_found(requ_json)
      else
        resp_json = campare_data(req_number, req_date_of_issue, req_valid_thru, req_name, req_given_names, req_birth_date, certificate )
        resp_json.blank? ? render_not_found(requ_json) : render_data_is_equal(requ_json, resp_json) 
      end
    end
  end

  # GET /api/v1/certificates/search – parametry: category, number_prefix, number, date_of_issue, valid_thru (pusta –
  # bezterminowe), name, given_names, birth_date.
  def search
    requ_json = { "category": "#{params[:category]}",
                  "number_prefix": "#{params[:number_prefix]}",
                  "number": "#{params[:number]}",
                  "date_of_issue": "#{params[:date_of_issue]}",
                  "valid_thru": "#{params[:valid_thru]}",
                  "name": "#{params[:name]}",
                  "given_names": "#{params[:given_names]}",
                  "birth_date": "#{params[:birth_date]}" }

    if !CATEGORIES.include?(params[:category]) || params[:number_prefix].blank? || params[:number].blank? || params[:date_of_issue].blank? || params[:name].blank? || params[:given_names].blank? || params[:birth_date].blank?
      render_not_params
    else
      req_number = ActionController::Base.helpers.sanitize("#{params[:number_prefix]}"+"#{params[:number]}")
      req_date_of_issue = ActionController::Base.helpers.sanitize(params[:date_of_issue])
      req_valid_thru = ActionController::Base.helpers.sanitize(params[:valid_thru]) # pusta dla świadectw bezterminowych
      req_name = ActionController::Base.helpers.sanitize(params[:name])
      req_given_names = ActionController::Base.helpers.sanitize(params[:given_names])
      req_birth_date = ActionController::Base.helpers.sanitize(params[:birth_date])

      certificate = Certificate.joins(:division)
                               .where(canceled: false, category: params[:category])
                               .find_by("TRIM(certificates.number) = ?", req_number)

      if certificate.blank?
        render_not_found(requ_json)
      else
        resp_json = campare_data(req_number, req_date_of_issue, req_valid_thru, req_name, req_given_names, req_birth_date, certificate )
        if resp_json.blank?
          render_not_found(requ_json) # dane się nie zgadzają – jak brak danych (bez ujawniania istnienia świadectwa)
        elsif !certificate.division.enabled_in_confirmation
          render_type_not_verifiable(requ_json) # dane OK, ale rodzaj wyłączony z weryfikacji internetowej
        else
          resp_json[:certificates].first[:verification_url] = certificate.qr_code_url
          render_data_is_equal(requ_json, resp_json)
        end
      end
    end
  end

  # GET /api/v1/certificates/search_by_code – parametr: code (kod świadectwa, wielkość liter bez znaczenia).
  # Kod ma tylko posiadacz karty / zaświadczenia, więc sam wystarcza do wyniku; dane aktualne (np. nazwisko po zmianie).
  # Brak kodu – 406; zły format, nieznany kod, świadectwo anulowane – 404 (bez rozróżniania).
  def search_by_code
    code = params[:code].to_s.strip.upcase
    requ_json = { "code": code }
    return render_not_params if code.blank?

    certificate = Certificate.includes(:division, :customer).find_by(verification_code: code, canceled: false) if code =~ Certificate::VERIFICATION_CODE_FORMAT
    if certificate.blank?
      render_not_found(requ_json)
    elsif !certificate.division.enabled_in_confirmation
      render_type_not_verifiable(requ_json)
    else
      render_data_is_equal(requ_json, certificate_found_json(certificate))
    end
  end

  private

    # Dane świadectwa zgadzają się (search) albo kod znaleziony (search_by_code), ale rodzaj nie jest dopuszczony
    # do weryfikacji internetowej (divisions.enabled_in_confirmation = false) – osobny komunikat (403).
    def render_type_not_verifiable(requ_json)
      resp_json = { error: "Rodzaj świadectwa nie podlega weryfikacji internetowej / Certificate type is not subject to online verification" }
      ConfirmationLog.create!(remote_ip: "#{request.headers['X-Real-IP']}", request_json: "#{requ_json}", response_json: "#{resp_json}")
      render status: :forbidden, json: resp_json
    end

    # Odpowiedź search_by_code – ten sam format co search (campare_data_with_current_record), z bieżących danych.
    def certificate_found_json(certificate)
      division = certificate.division
      customer = certificate.customer
      { "certificates": [
          { "id": certificate.id, "number": certificate.number.to_s.strip,
            "date_of_issue": certificate.date_of_issue.to_s, "valid_thru": certificate.valid_thru.to_s, "category": certificate.category,
            "division": { "id": division.id, "name": division.name, "english_name": division.english_name,
                          "short_name": division.short_name, "number_prefix": division.number_prefix },
            "customer": { "id": customer.id, "name": customer.name, "given_names": customer.given_names, "birth_date": customer.birth_date },
            "verification_url": certificate.qr_code_url }
        ],
        "meta": { "collection": { "offset": 0, "limit": 1, "objects": 1 } } }
    end


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
      resp_json = campare_data_with_current_record(number, date_of_issue, valid_thru, name, given_names, birth_date, certificate_record)
      resp_json = campare_data_with_history(number, date_of_issue, valid_thru, name, given_names, birth_date, certificate_record) if resp_json.blank?
      
      return resp_json
    end

    def campare_data_with_current_record(number, date_of_issue, valid_thru, name, given_names, birth_date, certificate_record)
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
                        "id": certificate_record.customer.id,
                        "name": certificate_record.customer.name,
                        "given_names": certificate_record.customer.given_names,
                        "birth_date": certificate_record.customer.birth_date
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
