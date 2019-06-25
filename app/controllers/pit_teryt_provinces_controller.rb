require 'net/http'

class PitTerytProvincesController < ApplicationController

  def show
    unless @provinces.present?
      @provinces, @status_code = provinces_array
    end

    array_provinces = JSON.parse(@provinces)
    province = array_provinces.select{ |row| row['id'].to_s == params[:id] }.map{ |row| row }

    render json: province[0], status: response.code 
  end

  def select2_index
    unless @provinces.present?
      @provinces, @status_code = provinces_array
    end

    array_provinces = JSON.parse(@provinces)
    @provinces_on_page = array_provinces.select{ |row| row['name'].include?(params[:q]) }.map{ |row| row }

    render json: @provinces_on_page, meta: {total_count: array_provinces.size}, status: @status_code
  end

  # def select2_index
  #   params[:q] = params[:q]
  #   @customers = Customer.order(:name, :given_names).finder_customer(params[:q])
  #   @customers_on_page = @customers.page(params[:page]).per(params[:page_limit])
    
  #   respond_to do |format|
  #     format.html
  #     format.json { 
  #       render json: @customers_on_page, each_serializer: CustomerSerializer, meta: {total_count: @customers.count}  
  #     }
  #   end
  # end

  private
    def provinces_array
      begin
        uri = URI("#{Rails.application.secrets[:teryt_api_url]}/Province")
        http = Net::HTTP.new(uri.host, uri.port)
        # SSL 
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
        # /SSL 
        response = Net::HTTP.get_response(uri)
        return response.body, response.code 
      rescue => e
        puts '=========================== API ERROR "/Province" ==========================='
        puts "#{e}"
        puts '============================================================================='
      end
    end

end
