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

  attr_accessor :response, :id_test_category, :test_name, :id_test, :id_attempt

  def initialize(params = {})
    @id_test = params.fetch(:id_test, '')
    @id_attempt = params.fetch(:id_attempt, '')
    @test_name = params.fetch(:test_name, '')
    @id_test_category = params.fetch(:id_test_category, '')
  end


  def request_for_collection
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/api/v1/manager/me/tests/headers")
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

  def request_for_one_row
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/api/v1/manager/me/tests/headers/#{@id_test}")
    # set query parameters
    # params = {}
    # params[:idTestCategory] = "#{@id_test_category}" unless @id_test_category.blank?
    # params[:name] = "#{@test_name}" unless @test_name.blank?
    # uri.query = URI.encode_www_form(params)
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
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_one_row"(1) ==============')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_one_row(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_one_row"(2) ==============')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_one_row(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPNotFound
      true
    when Net::HTTPForbidden
      true
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_one_row"(3) ==============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_one_row(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end

  def request_for_one_row_colletion_sheets
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/api/v1/manager/me/tests/#{@id_test}/test-sheets/headers")
    # set query parameters
    # params = {}
    # params[:idTestCategory] = "#{@id_test_category}" unless @id_test_category.blank?
    # params[:name] = "#{@test_name}" unless @test_name.blank?
    # uri.query = URI.encode_www_form(params)
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
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_one_row_colletion_sheets"(1) ==')
    Rails.logger.error("#{e}")
    Rails.logger.error('=====================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_one_row(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_one_row_colletion_sheets"(2) ==')
    Rails.logger.error("#{e}")
    Rails.logger.error('=====================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_one_row(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPNotFound
      true
    when Net::HTTPForbidden
      true
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_one_row_colletion_sheets"(3) ==')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=====================================================================================')
      errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_one_row(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end

  def request_for_one_sheets_pdf
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/api/v1/manager/me/tests/#{@id_test}/test-sheets/#{id_attempt}/pdf")
    # set query parameters
    # params = {}
    # params[:idTestCategory] = "#{@id_test_category}" unless @id_test_category.blank?
    # params[:name] = "#{@test_name}" unless @test_name.blank?
    # uri.query = URI.encode_www_form(params)
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
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_one_row_colletion_sheets"(1) ==')
    Rails.logger.error("#{e}")
    Rails.logger.error('=====================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_one_row(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_one_row_colletion_sheets"(2) ==')
    Rails.logger.error("#{e}")
    Rails.logger.error('=====================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_one_row(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPNotFound
      true
    when Net::HTTPForbidden
      true
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_one_row_colletion_sheets"(3) ==')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=====================================================================================')
      errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_one_row(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end




  def request_for_duplicate
    # uri = URI("http://localhost:3001/api/v1/exam_fees/find")
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/api/v1/manager/me/tests/#{@id_test}/duplicate")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL 
    http.use_ssl = true if uri.scheme == "https" 
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 

    req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json', 'API-Key' => "#{Rails.application.secrets[:testportal_api_key]}"})

    # params = {}
    # params[:duplicateTestName] = "#{@test_name}" 
    # req.body = params.to_json
    # @response = http.request(req)

    req.body = { "duplicateTestName" => "#{@test_name}" }.to_json

    @response = http.request(req)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_duplicate"(1) ============')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_duplicate(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_duplicate"(2) ============')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_duplicate(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError, Net::HTTPNoContent
      Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_duplicate"(3) ============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_duplicate(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end

  def request_for_activate
    # uri = URI("http://localhost:3001/api/v1/exam_fees/find")
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/api/v1/manager/me/tests/#{@id_test}/activate")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL 
    http.use_ssl = true if uri.scheme == "https" 
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 

    req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json', 'API-Key' => "#{Rails.application.secrets[:testportal_api_key]}"})

    @response = http.request(req)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_activate"(1) =============')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_activate(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_activate"(2) =============')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_activate(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError, Net::HTTPNoContent
      Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_activate"(3) =============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_activate(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end

  def request_for_destroy
    uri = URI("#{Rails.application.secrets[:testportal_api_url]}/api/v1/manager/me/tests/#{@id_test}")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL 
    http.use_ssl = true if uri.scheme == "https" 
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 
    req = Net::HTTP::Delete.new(uri.path, {'Content-Type' => 'application/json', 'API-Key' => "#{Rails.application.secrets[:testportal_api_key]}"})
    @response = http.request(req)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_destroy"(1) ==============')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_destroy(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_destroy"(2) ==============')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_destroy(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError, Net::HTTPNoContent
      Rails.logger.error('== API ERROR "models/api_testportal_test .request_for_destroy"(3) ==============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      errors.add(:base, "API ERROR 'models/api_testportal_test .request_for_destroy(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end


  # methods for external action
  def self.test_id_in_testportal_where_category_and_name(check_test_name, check_category_name)
    find_result = ""
    api_call_correct = false
    api_testtemplates_obj = ApiTestportalTest.new(test_name: "#{check_test_name}")
    api_call_correct = api_testtemplates_obj.request_for_collection
    if api_call_correct
      testtemplates_hash = JSON.parse(api_testtemplates_obj.response.body) if api_testtemplates_obj.response.body.present? 
      testtemplates_hash_without_root = testtemplates_hash['tests'] unless testtemplates_hash.blank?
      testtemplate_hash = testtemplates_hash_without_root.find {|x| (x["categoryName"] == "#{check_category_name}") && (x["name"] == "#{check_test_name}")} unless testtemplates_hash_without_root.blank?
      find_result = testtemplate_hash["idTest"] unless testtemplate_hash.blank?
    end
    return api_call_correct, find_result
  end

  def self.test_info_in_testportal_where_test_id(checked_id_test)
    hash_result = {}
    api_call_correct = false
    items_obj = ApiTestportalTest.new(id_test: "#{checked_id_test}")
    api_call_correct = items_obj.request_for_one_row
    if api_call_correct
      hash_result = JSON.parse(items_obj.response.body) if items_obj.response.class == Net::HTTPOK 
    end
    return api_call_correct, hash_result
  end

  # {"idTest"=>"IDrbtp6qOYySO8-GJyldADrz5z7_uUCKkWEJhgV9Xkek3IvaGzG642GAYDu1-DVo3A", 
  #   "name"=>"77/21/A___2. Bezpieczeństwo pracy przy urządzeniach elektrycznych i radiowych", 
  #   "description"=>"Kategoria C", 
  #   "creationTime"=>1636484171576, 
  #   "accessStartTimestamp"=>1624543137706, 
  #   "accessStart"=>"2021-06-24 15:58", 
  #   "status"=>"SETUP", 
  #   "frozen"=>false, 
  #   "categoryName"=>"R_C_47", 
  #   "idTestCategory"=>"IF5xPxrk5Fb8D6DRlPVf6KcbTwlxWHUnnV-Rz1XIQxc91EeCR2r1xSE5REE8iLv7IQ", 
  #   "publicId"=>"PeQvCGzuvstq", 
  #   "examLocale"=>"pl"}


  def self.duplicate_test_from_template(template_id_test, new_name_test)
    duplicate_result = ""
    api_call_correct = false
    item_obj = ApiTestportalTest.new(id_test: "#{template_id_test}", test_name: "#{new_name_test}")
    api_call_correct = item_obj.request_for_duplicate
    if api_call_correct
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
    return api_call_correct, duplicate_result
  end

  def self.get_all_headers_sheets_by_test_id(id_test)
    data_result = ""
    api_call_correct = false
    item_obj = ApiTestportalTest.new(id_test: "#{id_test}")
    api_call_correct = item_obj.request_for_one_row_colletion_sheets
    if api_call_correct
      item_hash = JSON.parse(item_obj.response.body) if item_obj.response.class == Net::HTTPOK 
      data_result = item_hash["testSheets"] unless item_hash.blank?
    end
    return api_call_correct, data_result    
  end

  def self.get_identifiers_headers_sheets_by_test_id(id_test)
    data_array = []
    api_call_correct, hash_result = ApiTestportalTest.test_info_in_testportal_where_test_id(id_test)
    if api_call_correct
      test_name = hash_result["name"]
      api_call_correct, data_result = ApiTestportalTest.get_all_headers_sheets_by_test_id("#{id_test}")
      if api_call_correct
        data_result.each do |e|
          id_attempt = e["idAttempt"]
          personaldata_fields_array = e["personalData"]["fieldsList"]
          nazwisko = personaldata_fields_array.select{|a| a["fieldName"] == "lastName"}[0]["fieldValue"]
          imie     = personaldata_fields_array.select{|a| a["fieldName"] == "firstName"}[0]["fieldValue"]
          code_id  = personaldata_fields_array.select{|a| a["fieldName"] == "passcode"}[0]["fieldValue"]
          data_array << { id_test: "#{id_test}",
                          name_test: "#{test_name}", 
                          id_attempt: "#{id_attempt}",
                          testportal_access_code_id: "#{code_id}", 
                          nazwisko: "#{nazwisko}",
                          imie: "#{imie}" }
        end
      end
    end
    return data_array
  end

  def self.testportal_whenever_tests_set
    start_run = Time.current
    puts '----------------------------------------------------------------'
    puts "  * ApiTestportalTest::testportal_whenever_tests_set"
    puts "  * START...: #{start_run}"

    test_recreate_for_defined_in_netpar_testportal_test_id
    test_sets_where_empty_in_netpar_testportal_test_id
    access_code_recreate_for_defined_in_netpar_testportal_access_code_id

    puts "START: #{start_run}  END: #{Time.current}"
    puts '----------------------------------------------------------------'
  end

  def self.testportal_whenever_tests_clean
    start_run = Time.current
    puts '----------------------------------------------------------------'
    puts "  * ApiTestportalTest::testportal_whenever_tests_clean"
    puts "  * START...: #{start_run}"

    test_clean_where_not_online_in_netpar_and_used_testportal_test_id

    puts "START: #{start_run}  END: #{Time.current}"
    puts '----------------------------------------------------------------'
  end

  def self.testportal_whenever_tests_activate
    start_run = Time.current
    puts '----------------------------------------------------------------'
    puts "  * ApiTestportalTest::testportal_whenever_tests_activate"
    puts "  * START...: #{start_run}"

    date_exam_today = (Time.zone.today).strftime("%Y-%m-%d")
    ExamsDivisionsSubject.joins(:subject, [exams_division: :exam]).where(exams: {online: true, date_exam: "#{date_exam_today}"}).where.not(testportal_test_id: "").reload.each do |eds|
      eds.testportal_test_activate
    end

    puts "START: #{start_run}  END: #{Time.current}"
    puts '----------------------------------------------------------------'
  end

  def self.test_recreate_for_defined_in_netpar_testportal_test_id
    # check exist id_test and recereate if deleted
    puts "  # Call test_recreate_for_defined_in_netpar_testportal_test_id..."
    ExamsDivisionsSubject.joins(:subject, [exams_division: :exam]).where(exams: {online: true}).where.not(testportal_test_id: "").reload.each do |eds|
      eds.check_and_recreate_testportal_test_id
    end    
  end

  def self.test_sets_where_empty_in_netpar_testportal_test_id
    puts "  # Call test_sets_where_empty_in_netpar_testportal_test_id..."
    ExamsDivisionsSubject.joins(:subject, [exams_division: :exam]).where(exams: {online: true}, testportal_test_id: "" ).reload.each do |eds|
      eds.set_testportal_test_id
    end    
  end

  def self.access_code_recreate_for_defined_in_netpar_testportal_access_code_id
    puts "  # Call access_code_recreate_for_defined_in_netpar_testportal_access_code_id..."
    # ExamsDivisionsSubject.joins(:subject, [exams_division: :exam]).where(exams: {online: true}, testportal_test_id: "" ).reload.each do |eds|
    #   eds.set_testportal_test_id
    # end    

    # puts "  # Call set_testportal_access_code_id..."
    # date_exam_min = (Time.zone.today).strftime("%Y-%m-%d")
    # extend_condition = "(exams.date_exam >= '#{date_exam_min}')" 
    # Grade.joins(examination: [:exam]).where(exams: {online: true}).where("#{extend_condition}").order("exams.date_exam, exams.number").reload.each do |grade|
    #   grade.set_testportal_access_code_id
    # end    

  end

  def self.test_clean_where_not_online_in_netpar_and_used_testportal_test_id
    puts "  # Call test_clean_where_not_online_in_netpar_and_used_testportal_test_id..."
    ExamsDivisionsSubject.joins(exams_division: [:exam]).where.not(testportal_test_id: "", exams: {online: true}).reload.each do |eds|
      eds.clean_testportal_test_id
    end    
  end


end
