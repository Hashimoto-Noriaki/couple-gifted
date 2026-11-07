module Api
  module V1
    class AuthController < ApplicationController
      # JSONのリクエストボディを{"auth": {...}}に包み直す機能を切る。トップレベルの
      # email等だけを受け取るため、包み直された"auth"キーがunpermittedとして毎回ログに出てしまう
      wrap_parameters false

      # ⚠️未実装：ログイン状態にするためのトークン発行は、sign_in・refreshの実装時に方式を決めて追加する
      # （doc/requirements.md 決定事項ログ #30、doc/api/openapi.yaml）
      def sign_up
        user = User.new(sign_up_params)

        if user.save
          render json: UserSerializer.new(user).as_json, status: :created
        else
          render_validation_problem(user.errors)
        end
      rescue ActiveRecord::RecordNotUnique
        # 一意性のバリデーション通過後、INSERTの時点で同じメールアドレスの登録に先を越された場合。
        # usersの一意制約はemailのみのため、通常の重複と同じ応答にする
        user.errors.add(:email, :taken)
        render_validation_problem(user.errors)
      end

      private

      # status等はクライアントから指定させない（停止・退会は運営・本人の別の操作でのみ変わる）
      def sign_up_params
        params.permit(:email, :password, :nickname)
      end
    end
  end
end
