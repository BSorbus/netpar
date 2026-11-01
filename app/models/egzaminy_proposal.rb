require 'net/http'

class EgzaminyProposal
  include ActiveModel::Model

  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error,
    Errno::ECONNREFUSED
  ]

  attr_accessor :egzaminy_proposal, :multi_app_identifier

  delegate *::Proposal.attribute_names.map { |attr| [attr, "#{attr}="] }.flatten, to: :egzaminy_proposal


  def initialize(params = {})
    @multi_app_identifier = params.fetch(:multi_app_identifier, '')
    # params egzaminy_proposal as Hash!
    @egzaminy_proposal = params.fetch("egzaminy_proposal".to_sym)
  end

  def request_update
    uri = URI("#{Rails.application.secrets[:egzaminy_api_url]}/api/v1/proposals/#{@multi_app_identifier}")
    request = Net::HTTP::Patch.new(uri)

    request["Content-Type"] = "application/json"
    request["Authorization"] = "Token token=#{EgzaminyUser.egzaminyuser_token}"

    proposal_rec = @egzaminy_proposal
    proposal_data = Hash.new
    proposal_data['proposal'] = proposal_rec.compact

    request.set_form_data( proposal_data )
    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https' ) do |http|
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
      http.request(request)
    end

    return response

  rescue *HTTP_ERRORS => e
    Rails.logger.error('======== API ERROR "models/egzaminy_proposal/request_update" (1) ==============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('=============================================================================')
    #false    # non-success response
    "#{e}"
  rescue StandardError => e
    Rails.logger.error('======== API ERROR "models/egzaminy_proposal/request_update" (2) ==============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('=============================================================================')
    #false    # non-success response
    "#{e}"
  else
    case response
    when Net::HTTPOK
      #true   # success response
      response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('======== API ERROR "models/egzaminy_proposal/request_update" (3) ==============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=============================================================================')
      #false  # non-success response
      response
    end
  end


  # Sekcja „Aplikacja Egzaminy” we wniosku – włączana w secrets.yml (egzaminy_details: true), gdy egzaminy_api_url wskazuje
  # aplikację Egzaminy z API szczegółów zgłoszenia (examinations8). Stara aplikacja go nie ma (zawsze 404) – bez wpisu sekcji nie ma.
  def self.details_enabled?
    Rails.application.secrets[:egzaminy_details].to_s == 'true'
  end

  # Szczegóły zgłoszenia z aplikacji Egzaminy (GET /api/v1/proposals/:multi_app_identifier): zgłoszenie, zgody RODO
  # zgłaszającego i historia zgłoszenia. Wynik: [true, Hash] albo [false, opis błędu] (panel w szczegółach wniosku).
  def self.find_details(multi_app_identifier)
    uri = URI("#{Rails.application.secrets[:egzaminy_api_url]}/api/v1/proposals/#{multi_app_identifier}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Token token=#{EgzaminyUser.egzaminyuser_token}"
    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE,
                               :open_timeout => 5, :read_timeout => 10) do |http|
      http.request(request)
    end

    case response
    when Net::HTTPOK
      [true, JSON.parse(response.body)]
    when Net::HTTPNotFound
      [false, I18n.t('pages.proposal_egzaminy.not_found')]
    else
      Rails.logger.error("API ERROR \"models/egzaminy_proposal/find_details\": code: #{response.code}, body: #{response.body.to_s[0, 300]}")
      [false, "HTTP #{response.code}"]
    end
  rescue StandardError => e
    Rails.logger.error("API ERROR \"models/egzaminy_proposal/find_details\": #{e.class}: #{e.message}")
    [false, e.message]
  end

end
