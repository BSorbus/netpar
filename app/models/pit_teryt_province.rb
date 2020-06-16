require 'net/http'

class PitTerytProvince
	include ActiveModel::Model

  attr_accessor :response, :q, :array_provinces, :array_query_provinces, :row_data, :id, :name

  def initialize(params = {})
    @id = params.fetch(:id, '0').to_i
    @q = params.fetch(:q, '')
  end

  def run_request
    begin
      uri = URI("#{Rails.application.secrets[:teryt_api_url]}/Province")
      http = Net::HTTP.new(uri.host, uri.port)
      # SSL 
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
      # /SSL 
      @response = Net::HTTP.get_response(uri)

      # for init :id - show or index
      @array_provinces = JSON.parse(@response.body)
      if @id > 0
        provinces = @array_provinces.select{ |row| row['id'].to_s == "#{@id}" }.map{ |row| row }
        @row_data = provinces[0]
        @id = @row_data['id']
        @name = @row_data['name']
      else 
        if @q.blank? #for index with query
          @array_query_provinces = @array_provinces
        else
          provinces = @array_provinces.select{ |row| row['name'].include?("#{@q}") }.map{ |row| row }
          @array_query_provinces = provinces
        end
      end
      # /for init :id
      return @response
    rescue => e
      puts '=========================== API ERROR "/Province" ==========================='
      puts "#{e}"
      puts '============================================================================='
    end
  end


end
