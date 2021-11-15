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


end
