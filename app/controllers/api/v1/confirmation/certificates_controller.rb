# Weryfikacja świadectw dla aplikacji Confirmation – wszystkie kategorie (L, M, R).
# Kontrakt jak w Api::V1::CertificatesController#mor_search_by_multi_params, dodatkowo parametr "category".
# Wyszukiwane są tylko świadectwa rodzajów z divisions.enabled_in_confirmation = true;
# świadectwo innego rodzaju daje taką samą odpowiedź jak brak danych.
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
                               .where(canceled: false, category: params[:category], divisions: { enabled_in_confirmation: true })
                               .find_by("TRIM(certificates.number) = ?", req_number)

      if certificate.blank?
        render_not_found(requ_json)
      else
        resp_json = campare_data(req_number, req_date_of_issue, req_valid_thru, req_name, req_given_names, req_birth_date, certificate )
        resp_json.blank? ? render_not_found(requ_json) : render_data_is_equal(requ_json, resp_json)
      end
    end
  end

end
