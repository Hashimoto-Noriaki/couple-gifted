require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { is_expected.to belong_to(:area).optional }
  it { is_expected.to have_secure_password }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:nickname) }
  it { is_expected.to validate_length_of(:nickname).is_at_most(User::NICKNAME_MAX_LENGTH) }

  it do
    is_expected.to define_enum_for(:age_band)
      .with_values(late_teens: 0, early_20s: 1, late_20s: 2, early_30s: 3, late_30s: 4, forties_and_over: 5)
  end

  it do
    is_expected.to define_enum_for(:relationship_stage)
      .with_values(early_dating: 0, mid_dating: 1, engaged: 2, newlywed: 3, married: 4)
  end

  it { is_expected.to define_enum_for(:status).with_values(active: 0, suspended: 1, withdrawn: 2) }

  describe "初期値" do
    it "状態はactive、子どもの有無はfalse、年代・関係ステージ・居住エリアは未設定（nil）" do
      user = User.new

      expect(user).to have_attributes(
        status: "active", has_children: false, age_band: nil, relationship_stage: nil, area_id: nil
      )
    end
  end

  describe "email" do
    it "前後の空白を除き、小文字にそろえて保存する" do
      user = create(:user, email: "  Hanako@Example.COM ")

      expect(user.email).to eq("hanako@example.com")
    end

    it "大文字小文字が違うだけのメールアドレスは登録済みとして弾く" do
      create(:user, email: "hanako@example.com")
      user = build(:user, email: "HANAKO@example.com")

      expect(user).not_to be_valid
      expect(user.errors.details[:email]).to include(a_hash_including(error: :taken))
    end

    it "停止済みの会員と同じメールアドレスでも登録済みとして弾く（停止の事実を伝えない）" do
      create(:user, email: "hanako@example.com", status: :suspended)
      user = build(:user, email: "hanako@example.com")

      expect(user).not_to be_valid
      expect(user.errors.details[:email]).to include(a_hash_including(error: :taken))
    end

    it "メールアドレスの形式でなければ弾く" do
      user = build(:user, email: "not-an-email")

      expect(user).not_to be_valid
      expect(user.errors.details[:email]).to include(a_hash_including(error: :invalid))
    end
  end

  describe "password" do
    it "#{User::PASSWORD_MIN_LENGTH}文字未満は弾く" do
      user = build(:user, password: "a" * (User::PASSWORD_MIN_LENGTH - 1))

      expect(user).not_to be_valid
      expect(user.errors.details[:password]).to include(a_hash_including(error: :too_short))
    end

    it "#{User::PASSWORD_MIN_LENGTH}文字ちょうどは登録できる" do
      user = build(:user, password: "a" * User::PASSWORD_MIN_LENGTH)

      expect(user).to be_valid
    end

    it "空なら誤りはblankだけを返す（too_shortを重ねない）" do
      user = build(:user, password: "")

      expect(user).not_to be_valid
      expect(user.errors.details[:password]).to eq([ { error: :blank } ])
    end

    it "空白だけの短いパスワードはtoo_shortで弾く（blank扱いで長さの検証を飛ばさない）" do
      user = build(:user, password: "  ")

      expect(user).not_to be_valid
      expect(user.errors.details[:password]).to contain_exactly(a_hash_including(error: :too_short))
    end

    it "#{User::PASSWORD_MAX_BYTES}バイトを超えるとtoo_longで弾く（bcryptの上限。文字数ではなくバイト数で数える）" do
      # 「あ」はUTF-8で3バイト。25文字 = 75バイト
      user = build(:user, password: "あ" * 25)

      expect(user).not_to be_valid
      expect(user.errors.details[:password]).to contain_exactly(a_hash_including(error: :too_long))
    end

    it "#{User::PASSWORD_MAX_BYTES}バイトちょうどは登録できる" do
      user = build(:user, password: "あ" * 24)

      expect(user).to be_valid
    end

    it "平文では保存しない" do
      user = create(:user, password: "password123")

      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq("password123")
      expect(user.authenticate("password123")).to eq(user)
    end
  end
end
