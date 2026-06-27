module Api
  module V1
    class LikesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_spot_review

      def create
        like = @spot_review.likes.build(user: current_user)

        if like.save
          render json: { likes_count: @spot_review.likes.count }, status: :created
        else
          render json: { error: like.errors.full_messages.join(", ") }, status: :conflict
        end
      rescue ActiveRecord::RecordNotUnique
        render json: { error: "すでにいいね済みです" }, status: :conflict
      end

      def destroy
        like = @spot_review.likes.find_by(user: current_user)

        if like
          like.destroy!
          head :no_content
        else
          render json: { error: "いいねが見つかりません" }, status: :not_found
        end
      end

      private

      def set_spot_review
        @spot_review = SpotReview.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "口コミが見つかりません" }, status: :not_found
      end
    end
  end
end
