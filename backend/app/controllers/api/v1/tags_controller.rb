module Api
  module V1
    class TagsController < ApplicationController
      def index
        tags = Tag.order(:id)
        render json: TagSerializer.new(tags).serializable_hash
      end
    end
  end
end
