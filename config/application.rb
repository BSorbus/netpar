require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Netpar
  class Application < Rails::Application

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Warsaw'
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]


    #config.i18n.default_locale = :en
    config.i18n.default_locale = :pl
    #config.i18n.available_locales = [:en, :pl]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # for MySoap module
    # config.autoload_paths += %W(#{config.root}/lib)

    # cos jest nie halo - zmiana dotyczy refile-postgres 1.3.0
    #config.active_record.schema_format = :sql

    #config.middleware.insert_before 0, "Rack::Cors" do
    #  allow do
    #    origins '*'
    #    resource '*', :headers => :any, :methods => [:get, :post, :options]
    #  end
    #end

    # config.middleware.insert_before 0, "Rack::Cors", :debug => true, :logger => (-> { Rails.logger }) do
    #   allow do
    #     origins '127.0.0.1:3000, localhost:3000, netpar2015.uke.gov.pl, netpar2015-test.uke.gov.pl, 10.100.2.87, 10.100.2.86'
    #     resource '*',
    #       :headers => :any,
    #       :methods => [:get, :post, :delete, :put, :patch, :options, :head],
    #       :max_age => 0
    #   end
    # end


  end
end
