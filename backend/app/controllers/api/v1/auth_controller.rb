module Api
  module V1
    class AuthController < ApplicationController
      # ⚠️未実装：ログイン状態にするためのトークン発行は、sign_in・refreshの実装時に方式を決めて追加する
      # （doc/requirements.md 決定事項ログ #30、doc/api/openapi.yaml）
      def sign_up
        user = User.new(sign_up_params)

        if user.save
          render json: UserSerializer.new(user).as_json, status: :created
        else
          render_validation_problem(user.errors)
        end
      end

      private

      # status等はクライアントから指定させない（停止・退会は運営・本人の別の操作でのみ変わる）
      def sign_up_params
        params.permit(:email, :password, :nickname)
      end
    end
  end
end
