module Api
  module V1
    class SpotReviewsController < ApplicationController
      before_action :authenticate_user!, only: %i[create destroy]

      def index
        spot = Spot.find(params[:spot_id])
        reviews = spot.spot_reviews.includes(:user)
        render json: SpotReviewSerializer.new(reviews).serializable_hash
      rescue ActiveRecord::RecordNotFound
        render json: { error: "スポットが見つかりません" }, status: :not_found
      end

      def create
        spot = Spot.find(params[:spot_id])
        review = spot.spot_reviews.build(spot_review_params.merge(user: current_user))

        if review.save
          render json: SpotReviewSerializer.new(review).serializable_hash, status: :created
        else
          render json: { error: review.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "スポットが見つかりません" }, status: :not_found
      end

      def destroy
        review = SpotReview.find(params[:id])

        unless review.owned_by?(current_user)
          
          render json: { error: "権限がありません" }, status: :forbidden
          return
        end

        review.destroy!
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: "口コミが見つかりません" }, status: :not_found
      end

      private

      def spot_review_params
        params.permit(:rating, :body, :relationship_status_at_visit)
      end
    end
  end
end
