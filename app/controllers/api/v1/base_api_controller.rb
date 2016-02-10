module Api
  module V1
    class BaseApiController < ApplicationController

      include Authenticable

    end
  end
end