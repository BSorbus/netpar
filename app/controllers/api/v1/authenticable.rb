module Api
  module V1
    module Authenticable

# name: "confirmation", 
# password: "6bad510135efb2f7e3ffc272579fb3f2", 
# access_token: "a42e10ee38d0234af8cbfd61adda659b"
#    Base64.encode64("#{name}:#{password}") or self.encode64_name_and_pass
#    "29uZmlybWF0aW9uOjZiYWQ1MTAxMzVlZmIyZjdlM2ZmYzI3MjU3OWZiM2Yy\n"

# name: "egzaminy", 
# password: "924a1a4beb2adec70e707dccc592cdf0", 
# access_token: "ec201be20877c273ea69dd1dc31b3878"
#    Base64.encode64("#{name}:#{password}") or self.encode64_name_and_pass
#    "ZWd6YW1pbnk6OTI0YTFhNGJlYjJhZGVjNzBlNzA3ZGNjYzU5MmNkZjA=\n"



      def token
        authenticate_with_http_basic do |username, password|
          system_for_api = ApiKey.find_by(name: username)
          if system_for_api && system_for_api.password == password
            render json: { token: system_for_api.access_token }, status: 200
          else
            render json: { error: 'Incorrect credentials' }, status: 401
          end
        end
      end


      def authenticate_system_from_token
        unless authenticate_with_http_token { |token, options| ApiKey.find_by(access_token: token) }
          render json: { error: 'Bad Token'}, status: 401
        end
      end


    end
  end
end