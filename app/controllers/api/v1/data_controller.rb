module Api
  module V1
    class DataController < ApplicationController
      def index
        render json: "Hey form controller", status: :ok
      end
    end
  end
end
