require 'net/http'

class ApiTestportalTest
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

  attr_accessor :response, :id_test_category, :test_name, :id_test

  def initialize(params = {})
    @id_test = params.fetch(:id_test, '')
    @test_name = params.fetch(:test_name, '')
    @id_test_category = params.fetch(:id_test_category, '')
  end


  def request_for_collection
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/manager/me/tests/headers")
    # set query parameters
    params = {}
    params[:idTestCategory] = "#{@id_test_category}" unless @id_test_category.blank?
    params[:name] = "#{@test_name}" unless @test_name.blank?
    uri.query = URI.encode_www_form(params)
    # /set query parameters
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
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_collection"(1) ===========')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_collection(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_collection"(2) ===========')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_collection(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_collection"(3) ===========')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_collection(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end

  def request_for_duplicate
    # uri = URI("http://localhost:3001/api/v1/exam_fees/find")
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/manager/me/tests/#{@id_test}/duplicate")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL 
    http.use_ssl = true if uri.scheme == "https" 
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 

    req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json', 'API-Key' => "#{Rails.application.secrets[:testportal_api_key]}"})

    # # params = {:division_id => "20", :esod_category => "42"}
    # params = {}
    # params[:request_body] = { } 
    # req.body = params.to_json
    # @response = http.request(req)

    # req.body = { "request_body" => {"duplicateTestName" => "#{@test_name}"} }.to_json
    req.body = { "duplicateTestName" => "#{@test_name}" }.to_json

    @response = http.request(req)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_duplicate"(1) ============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('================================================================================')
    #false    # non-success response
    "#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_duplicate"(2) ============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('================================================================================')
    #false    # non-success response
    "#{e}"
  else
    case response
    when Net::HTTPOK
      #true   # success response
      response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_duplicate"(3) ============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      #false  # non-success response
      response
    end
  end


  def request_for_destroy
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/manager/me/tests/#{@id}")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL 
    http.use_ssl = true if uri.scheme == "https" 
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 
    req = Net::HTTP::Delete.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "Token token=#{NetparUser.netparuser_token}"})
    @response = http.request(req)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_destroy"(1) ==============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('================================================================================')
    #false    # non-success response
    "#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_destroy"(2) ==============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('================================================================================')
    #false    # non-success response
    "#{e}"
  else
    case response
    when Net::HTTPNoContent
      #true   # success response
      response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_destroy"(3) ==============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      #false  # non-success response
      response
    end
  end


  # methods for external action
  def self.test_id_in_testportal_where_category_and_name(check_test_name, check_category_name)
    find_result = ""
    api_testtemplates_obj = ApiTestportalTest.new(test_name: "#{check_test_name}")
    if api_testtemplates_obj.request_for_collection
      testtemplates_hash = JSON.parse(api_testtemplates_obj.response.body) if api_testtemplates_obj.response.body.present? 
      testtemplates_hash_without_root = testtemplates_hash['tests'] unless testtemplates_hash.blank?
      testtemplate_hash = testtemplates_hash_without_root.find {|x| (x["categoryName"] == "#{check_category_name}") && (x["name"] == "#{check_test_name}")} unless testtemplates_hash_without_root.blank?
      find_result = testtemplate_hash["idTest"] unless testtemplate_hash.blank?
    end
    find_result
  end

  def self.check_exist_test_in_testportal(checked_id_test)
    find_result = ""
    items_obj = ApiTestportalTest.new()
    if items_obj.request_for_collection
      testtemplates_hash = JSON.parse(items_obj.response.body) if items_obj.response.body.present? 
      testtemplates_hash_without_root = testtemplates_hash['tests'] unless testtemplates_hash.blank?
      testtemplate_hash = testtemplates_hash_without_root.find {|x| (x["idTest"] == "#{checked_id_test}")} unless testtemplates_hash_without_root.blank?
      find_result = testtemplate_hash["name"] unless testtemplate_hash.blank?
    end
    find_result
  end

  def self.duplicate_test_from_template(template_id_test, new_name_test)
    duplicate_result = ""
    item_obj = ApiTestportalTest.new(id_test: "#{template_id_test}", test_name: "#{new_name_test}")
    if item_obj.request_for_duplicate # return true
      item_hash = JSON.parse(item_obj.response.body)

      # { "idTest"=>"ILVSuB2SeUUTToCnw5CNDtBkS4irBVe4kE81s5wr_Nb0piLalBYPbM7D2_UtK4_ZNQ", 
      #   "name"=>"BBBBBBBBBBBBBB from WZORZEC_R_A_45", 
      #   "description"=>"", 
      #   "creationTime"=>1636049167572, 
      #   "accessStartTimestamp"=>nil, 
      #   "accessStart"=>nil, 
      #   "status"=>"SETUP", 
      #   "frozen"=>false, 
      #   "categoryName"=>"R_A_45", 
      #   "idTestCategory"=>"IBHge3NwU5GecP80ZryPCjYSXSU0E-EXI1G29EV8zVpTrsXlbR8XM5O3-J_Rp0hZvA", 
      #   "publicId"=>"kM2C9KQViCYb", 
      #   "examLocale"=>"en"}

      duplicate_result = item_hash["idTest"] unless item_hash.blank?
    end
    duplicate_result
  end

  def self.testportal_whenever_tests_set
    start_run = Time.current
    puts '----------------------------------------------------------------'
    puts "task testportal_set_tests run...START: #{start_run}"
    puts "ApiTestportalTest::testportal_whenever_tests_set"

    # check exist id_test and recereate if deleted
    puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '
    puts "check_and_recreate_testportal_test_id..."
    # Tylko dla wpisów powiązanych z sesjami typu Online
    # ExamsDivisionsSubject.where.not(testportal_test_id: "").each do |eds|
    ExamsDivisionsSubject.joins(:subject, [exams_division: :exam]).where(exams: {online: true} ).where.not(testportal_test_id: "").each do |eds|
      eds.check_and_recreate_testportal_test_id
    end    
    # add other select params
    puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '
    puts "set_testportal_test_id..."
    # ExamsDivisionsSubject.where(testportal_test_id: "").each do |eds|
    ExamsDivisionsSubject.joins(:subject, [exams_division: :exam]).where(testportal_test_id: "", exams: {online: true} ).each do |eds|
      eds.set_testportal_test_id
    end    

    puts "START: #{start_run}  END: #{Time.current}"
    puts '----------------------------------------------------------------'
  end

  def self.testportal_whenever_tests_clean
    start_run = Time.current
    puts '----------------------------------------------------------------'
    puts "task testportal_set_tests run...START: #{start_run}"

    # add other select params
    ExamsDivisionsSubject.where.not(testportal_test_id: "").each do |eds|
      puts "id: #{eds.id}"
      # eds.set_testportal_test_id
    end    

    puts "START: #{start_run}  END: #{Time.current}"
    puts '----------------------------------------------------------------'
  end


end
