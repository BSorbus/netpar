require 'net/http'

class ApiTestportalCategory
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

  attr_accessor :response

  def initialize(params = {})

  end


  def request_for_collection
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/api/v1/manager/me/tests/categories")
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
    Rails.logger.error('== API ERROR "models/api_testportal_category .request_for_collection"(1) =======')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_category .request_for_collection(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_category .request_for_collection"(2) =======')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_category .request_for_collection(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('== API ERROR "models/api_testportal_category .request_for_collection"(3) =======')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      errors.add(:base, "API ERROR 'models/api_testportal_category .request_for_collection(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end

  # def category_id_in_testportal
  #   find_result = ""
  #   api_categories_obj = ApiTestportalCategory.new()
  #   if api_categories_obj.request_for_collection
  #     categories_hash = JSON.parse(api_categories_obj.response.body) if api_categories_obj.response.body.present? 
  #     categories_hash_without_root = categories_hash['testCategories'] unless categories_hash.blank?
  #     category_hash = categories_hash_without_root.find {|x| x["name"] == "#{self.exams_division.exam.category}_#{self.exams_division.division.short_name}_#{self.subject.id}"} unless categories_hash_without_root.blank?
  #     find_result = category_hash["idTestCategory"] unless category_hash.blank?
  #   end
  #   find_result
  # end

end
