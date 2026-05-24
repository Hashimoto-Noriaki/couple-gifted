module Api
  module V1
    class SpotsController < ApplicationController
      def index
        spots = Spot.all.by_tag(params[:tag]).by_area(params[:area])
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
