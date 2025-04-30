module Api
  module V1
    class DataController < ApplicationController
      def index
        validator = DataRequestValidator.new(params)

        return render json: { errors: validator.errors }, status: :bad_request unless validator.valid?

        page_fetcher_result = PageFetcherService.call(validator.url)

        if page_fetcher_result.success?
          result = ScraperService.call(page_fetcher_result.html, validator.fields)

          render json: result, status: :ok
        else
          render json: { errors: page_fetcher_result.error }, status: :bad_gateway
        end
      end
    end
  end
end
