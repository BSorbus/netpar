# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application

require 'rack/cors'

use Rack::Cors, :debug => true, :logger => (-> { Rails.logger }) do

  allow do
    origins '127.0.0.1:3000, localhost:3000, netpar2015.uke.gov.pl:443, netpar2015-test.uke.gov.pl:443, 10.100.2.87:443, 10.100.2.86:443'
    resource '*',
      :headers => :any,
      :methods => [:get, :post, :delete, :put, :patch, :options, :head],
      :max_age => 0
  end
end
