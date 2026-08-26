module Api
  module V1
    class AreasController < ApplicationController
      def index
        render json: AreaListSerializer.new(Area.ordered).as_json
      end
    end
  end
end
