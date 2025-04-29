module Api
  module V1
    class DataController < ApplicationController
      def index
        result = ScraperService.call(params[:url], params[:fields])

        render json: result, status: :ok
      end
    end
  end
end
