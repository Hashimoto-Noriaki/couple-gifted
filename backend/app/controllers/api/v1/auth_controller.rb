module Api
  module V1
    class AuthController < ApplicationController
      # JSONのリクエストボディを{"auth": {...}}に包み直す機能を切る。トップレベルの
      # email等だけを受け取るため、包み直された"auth"キーがunpermittedとして毎回ログに出てしまう
      wrap_parameters false

      before_action :authenticate!, only: :sign_out

      # ⚠️未実装：登録と同時にログイン状態にする（トークンを返す）ことは未対応
      # （doc/api/openapi.yaml「/auth/sign_up」）
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

      # ⚠️未実装：連続して失敗した場合の試行制限（doc/use-cases.md「ログインする」例外フロー、issue #111）
      def sign_in
        # authenticate_byは、パスワードが渡されていれば会員が見つからなくても照合と同じだけ時間をかける
        # （応答時間の差からメールアドレスの登録有無を推測させない）。パスワードが空のときは照合せず
        # すぐ返すが、メールアドレスを問わず同じなので登録有無の手がかりにはならない。
        # to_s：文字列以外が送られても500にしない（スキーマ検証は本番では行わない）
        user = User.authenticate_by(email: params[:email].to_s, password: params[:password].to_s)

        # 退会済みは「登録されていない」と区別しない（doc/api-design.md「設計上の判断 7」）
        return render_invalid_credentials if user.nil? || user.withdrawn?
        # 停止中はパスワードまで正しいときだけ伝える（doc/use-cases.md「ログインする」）
        return render_account_suspended if user.suspended?

        render json: AuthTokensSerializer.new(AuthSession.start_for(user)).as_json
      end

      def refresh
        refresh_token = params[:refresh_token].to_s
        auth_session = AuthSession.find_by_refresh_token(refresh_token)

        if auth_session.nil?
          # 入れ替え済みのトークンが再び使われた場合は、盗用とみなしてセッションごと失効させる
          AuthSession.revoke_by_reused_refresh_token(refresh_token)
          return render_unauthenticated
        end

        # rotate_refresh_token!がfalse：同じトークンでの同時更新に先を越された（使用済みと同じ扱い）
        unless auth_session.user.active? && auth_session.rotate_refresh_token!
          return render_unauthenticated
        end

        render json: AuthTokensSerializer.new(auth_session).as_json
      end

      # いまのログイン（認証セッション）だけを消す。他の端末のログインはそのまま
      def sign_out
        current_auth_session.destroy!
        head :no_content
      end

      private

      # status等はクライアントから指定させない（停止・退会は運営・本人の別の操作でのみ変わる）
      def sign_up_params
        params.permit(:email, :password, :nickname)
      end

      # メールアドレスが無い・パスワード違い・退会済みを区別しない
      def render_invalid_credentials
        response.headers["WWW-Authenticate"] = "Bearer"
        render_problem(
          status: :unauthorized,
          type: "#{ProblemSerializer::BASE_URI}/invalid-credentials",
          title: "メールアドレスまたはパスワードが正しくありません"
        )
      end

      def render_account_suspended
        render_problem(
          status: :forbidden,
          type: "#{ProblemSerializer::BASE_URI}/account-suspended",
          title: "このアカウントは停止されています"
        )
      end
    end
  end
end
