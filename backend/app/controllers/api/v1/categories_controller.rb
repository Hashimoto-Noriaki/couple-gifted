module Api
  module V1
    class CategoriesController < ApplicationController
      def index
        render json: CategoryListSerializer.new(Category.ordered).as_json
      end
    end
  end
end
