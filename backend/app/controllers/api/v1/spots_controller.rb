module Api
  module V1
    class SpotsController < ApplicationController
      DEFAULT_LIMIT = 20
      MAX_LIMIT = 100

      def index
        created_at, id = Spot.decode_cursor(params[:cursor])

        spots = Spot.published
        spots = spots.where(area_id: params[:area_id]) if params[:area_id].present?
        spots = spots.where(category_id: params[:category_id]) if params[:category_id].present?
        spots = spots.ordered_for_listing
        spots = spots.after_cursor(created_at, id) if created_at

        page = spots.limit(limit_param + 1).to_a
        has_more = page.size > limit_param
        page = page.first(limit_param)

        render json: SpotListSerializer.new(
          page,
          next_cursor: has_more ? Spot.encode_cursor(page.last) : nil
        ).as_json
      rescue ArgumentError => e
        render_problem(
          status: :bad_request,
          type: "#{ProblemSerializer::BASE_URI}/bad-request",
          title: e.message
        )
      end

      def show
        spot = Spot.published.find(params[:id])

        # ⚠️未実装：認証導入前は本人を判定できないため、常にfalse（doc/api/openapi.yaml参照）
        render json: SpotDetailSerializer.new(spot, saved: false).as_json
      end

      private

      def limit_param
        return DEFAULT_LIMIT if params[:limit].blank?

        # limitは配列・Hashでも送られ得る（例：limit[]=1&limit[]=2）。Array/Hashに#to_iは無く
        # NoMethodErrorになってしまうため、Stringであることを先に確認する
        raise ArgumentError, "limitが不正です" unless params[:limit].is_a?(String)

        params[:limit].to_i.clamp(1, MAX_LIMIT)
      end
    end
  end
end
