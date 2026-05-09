module Api
  module V1
    class SpotsController < ApplicationController
      def index
        spots = Spot.all
        spots = spots.joins(:tags).where(tags: { name: params[:tag] }).distinct if params[:tag].present?
        spots = spots.where("address LIKE ?", "%#{params[:area]}%") if params[:area].present?
        render json: SpotSerializer.new(spots).serializable_hash
      end

      def show
        spot = Spot.find(params[:id])
        render json: SpotSerializer.new(spot).serializable_hash
      rescue ActiveRecord::RecordNotFound
        render json: { error: "スポットが見つかりません" }, status: :not_found
      end
    end
  end
end
