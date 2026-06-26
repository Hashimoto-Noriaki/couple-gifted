module Api
  module V1
    class SpotReviewsController < ApplicationController
      before_action :authenticate_user!, only: %i[create destroy]
      before_action :set_spot, only: %i[index create]
      before_action :set_review, only: %i[destroy]
      before_action :authorize_owner!, only: %i[destroy]

      def index
        reviews = @spot.spot_reviews.includes(:user)
        render json: SpotReviewSerializer.new(reviews).serializable_hash
      end

      def create
        review = @spot.spot_reviews.build(spot_review_params.merge(user: current_user))

        if review.save
          render json: SpotReviewSerializer.new(review).serializable_hash, status: :created
        else
          render json: { error: review.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      def destroy
        @review.destroy!
        head :no_content
      end

      private

      def set_spot
        @spot = Spot.find(params[:spot_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "スポットが見つかりません" }, status: :not_found
      end

      def set_review
        @review = SpotReview.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "口コミが見つかりません" }, status: :not_found
      end

      def authorize_owner!
        render json: { error: "権限がありません" }, status: :forbidden unless @review.owned_by?(current_user)
      end

      def spot_review_params
        params.permit(:rating, :body, :relationship_status_at_visit)
      end
    end
  end
end
