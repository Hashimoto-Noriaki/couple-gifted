class User < ApplicationRecord
  PASSWORD_MIN_LENGTH = 8
  NICKNAME_MAX_LENGTH = 50

  # 認証情報を平文で保持しない（doc/requirements.md 非機能要件、決定事項ログ #30）。
  # 72バイト上限・作成時の必須チェックはhas_secure_passwordが行う
  has_secure_password

  # 居住エリア。未設定（null）を許す（doc/er-and-db-design.md）
  belongs_to :area, optional: true

  # 選択肢はdoc/er-and-db-design.md「決めた選択肢」。nilは未設定
  enum :age_band, {
    late_teens: 0, early_20s: 1, late_20s: 2, early_30s: 3, late_30s: 4, forties_and_over: 5
  }, validate: { allow_nil: true }
  # 交際初期／交際中期／婚約中／新婚／夫婦（doc/ubiquitous-language.md）。nilは未設定
  enum :relationship_stage, {
    early_dating: 0, mid_dating: 1, engaged: 2, newlywed: 3, married: 4
  }, validate: { allow_nil: true }
  enum :status, { active: 0, suspended: 1, withdrawn: 2 }

  # 大文字小文字・前後の空白だけが違うメールアドレスで重複登録させない
  normalizes :email, with: ->(email) { email.strip.downcase }

  # 停止済み・退会済みの会員とも重複させない（停止の事実を伝えない。doc/use-cases.md「新規登録する」）
  validates :email, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :nickname, presence: true, length: { maximum: NICKNAME_MAX_LENGTH }
  validates :password, length: { minimum: PASSWORD_MIN_LENGTH }, allow_nil: true
end
