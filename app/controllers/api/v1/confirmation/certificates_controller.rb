# Weryfikacja świadectw dla aplikacji Confirmation – wszystkie kategorie (L, M, R).
# Kontrakt jak w Api::V1::CertificatesController#mor_search_by_multi_params, dodatkowo parametr "category".
# Świadectwo szukane jest po numerze i kategorii; dane osobowe muszą się zgodzić jak przy pozytywnej weryfikacji.
# Gdy dane się zgadzają, ale rodzaj świadectwa nie jest dopuszczony do weryfikacji internetowej
# (divisions.enabled_in_confirmation = false), zwracamy osobną odpowiedź (403) – „typ spoza weryfikacji internetowej”.
# Osobny komunikat pojawia się dopiero po pełnym dopasowaniu danych, więc po samym numerze nie da się wykryć istnienia świadectwa.
class Api::V1::Confirmation::CertificatesController < Api::V1::CertificatesController

  CATEGORIES = %w(L M R)

  # GET /api/v1/confirmation/certificates/search
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
          render_data_is_equal(requ_json, resp_json)
        end
      end
    end
  end

  private
    # Dane świadectwa zgadzają się, ale jego rodzaj nie jest dopuszczony do weryfikacji internetowej
    # (divisions.enabled_in_confirmation = false). Osobny komunikat (403), dopiero po pełnym dopasowaniu danych.
    def render_type_not_verifiable(requ_json)
      resp_json = { error: "Rodzaj świadectwa nie podlega weryfikacji internetowej / Certificate type is not subject to online verification" }
      ConfirmationLog.create!(remote_ip: "#{request.headers['X-Real-IP']}", request_json: "#{requ_json}", response_json: "#{resp_json}")
      render status: :forbidden, json: resp_json
    end

end
