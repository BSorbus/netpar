require 'net/http'

class ApiTestportalAccessCode
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

  attr_accessor :response, :id_code, :id_test

  def initialize(params = {})
    @id_test = params.fetch(:id_test, '')

  end

  def request_for_collection
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/api/v1/manager/me/tests/#{@id_test}/current-date/access-codes")
    # set query parameters
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL
    http.use_ssl = true if uri.scheme == "https"
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL

    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "UKE Egzaminy"
    request["Content-Type"] = "application/json"
    request["API-Key"] = "#{Rails.application.secrets[:testportal_api_key]}"

    @response = http.request(request)


  rescue *HTTP_ERRORS => e
    Rails.logger.error('== API ERROR "models/api_testportal_access_code .request_for_collection"(1) ====')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_access_code .request_for_collection(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_access_code .request_for_collection"(2) ====')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_access_code .request_for_collection(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('== API ERROR "models/api_testportal_access_code .request_for_collection"(3) ====')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      errors.add(:base, "API ERROR 'models/api_testportal_access_code .request_for_collection(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end

  def request_for_access_code_add
    # uri = URI("http://localhost:3001/api/v1/exam_fees/find")
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/api/v1/manager/me/tests/#{@id_test}/current-date/access-codes/add")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL 
    http.use_ssl = true if uri.scheme == "https" 
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 

    req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json', 'API-Key' => "#{Rails.application.secrets[:testportal_api_key]}"})

    params = {}
    params[:count] = "1" 
    params[:sendInvitationOnTestActivation] = "false" 
    req.body = params.to_json
    # req.body = { "count" => "1", "sendInvitationOnTestActivation" => "false" }.to_json

    @response = http.request(req)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('== API ERROR "models/api_testportal_access_code .request_for_access_code_add"(1)')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_access_code .request_for_access_code_add(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_access_code .request_for_access_code_add"(2)')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_access_code .request_for_access_code_add(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError, Net::HTTPNoContent
      Rails.logger.error('== API ERROR "models/api_testportal_access_code .request_for_access_code_add"(3)')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      errors.add(:base, "API ERROR 'models/api_testportal_access_code .request_for_access_code_add(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end

  def self.access_code_add_to_test(id_test)
    access_code_result = {}
    api_call_correct = false
    item_obj = ApiTestportalAccessCode.new(id_test: "#{id_test}")
    api_call_correct = item_obj.request_for_access_code_add
    if api_call_correct
      # item_hash = JSON.parse(item_obj.response.body)
      # access_code_result = item_hash["accessCodes"].first["accessCode"] unless item_hash.blank?
      # # { "idTest"=>"IDrbtp6qOYySO8-GJyldADrz5z7_uUCKkWEJhgV9Xkek3IvaGzG642GAYDu1-DVo3A", 
      # #   "idTerm"=>"II9MdrdATMPNbpJVL6H9mFncS-ncjtmOpwEdBphV6KIPJfwffNMEM3qQmADWRPqZxg", 
      # #   "accessCodes"=>[
      # #     {"idRespondent"=>"IKvyyDVeXZXzCjZzfHsw0arejgO4BrZQKJ8iMM5fkvMN7iCZXem8yZApwH0cI5zoWQ", 
      # #       "accessCode"=>"tNBrPMxtKkBA", 
      # #       "sendInvitationOnTestActivation"=>false, 
      # #       "used"=>false}
      # #     ]
      # #   }
      access_code_result = JSON.parse(item_obj.response.body)
    end
    return api_call_correct, access_code_result
  end

end
