module Api
  module V1
    class SpotReviewsController < ApplicationController
      def index
        spot = Spot.find(params[:spot_id])
        reviews = spot.spot_reviews.includes(:user)
        render json: SpotReviewSerializer.new(reviews).serializable_hash
      rescue ActiveRecord::RecordNotFound
        render json: { error: "スポットが見つかりません" }, status: :not_found
      end
    end
  end
end
