# Be sure to restart your server when you modify this file.

#Rails.application.config.session_store :cookie_store, key: '_amator_session'
Rails.application.config.session_store :cookie_store, key: '_netpar_session', secure: Rails.env.production?, http_only: true
