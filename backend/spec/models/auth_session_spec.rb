require "rails_helper"

RSpec.describe AuthSession, type: :model do
  let(:user) { create(:user) }

  it { is_expected.to belong_to(:user) }

  describe ".start_for" do
    it "会員の認証セッションを作り、平文のリフレッシュトークンはDBに保存しない" do
      session = described_class.start_for(user)

      expect(session).to be_persisted
      expect(session.user).to eq(user)
      expect(session.refresh_token).to be_present
      expect(session.refresh_token_digest).not_to eq(session.refresh_token)
      expect(session.refresh_token_digest).to eq(Digest::SHA256.hexdigest(session.refresh_token))
    end

    it "リフレッシュトークンの有効期限は#{AuthSession::REFRESH_TOKEN_TTL.inspect}後" do
      freeze_time do
        session = described_class.start_for(user)

        expect(session.refresh_token_expires_at).to eq(AuthSession::REFRESH_TOKEN_TTL.from_now)
      end
    end

    it "start_for以外の作り方（関連経由のcreate!）でも、リフレッシュトークンが発行される" do
      session = user.auth_sessions.create!

      expect(session.refresh_token).to be_present
      expect(session.refresh_token_digest).to eq(Digest::SHA256.hexdigest(session.refresh_token))
    end

    it "ログインのたびに別のセッション・別のリフレッシュトークンになる" do
      first = described_class.start_for(user)
      second = described_class.start_for(user)

      expect(second.id).not_to eq(first.id)
      expect(second.refresh_token).not_to eq(first.refresh_token)
    end
  end

  describe ".find_by_access_token" do
    let(:session) { described_class.start_for(user) }

    it "アクセストークンからセッションを引ける" do
      expect(described_class.find_by_access_token(session.access_token)).to eq(session)
    end

    it "#{AuthSession::ACCESS_TOKEN_TTL.inspect}を過ぎたアクセストークンでは引けない" do
      token = session.access_token

      travel(AuthSession::ACCESS_TOKEN_TTL + 1.second) do
        expect(described_class.find_by_access_token(token)).to be_nil
      end
    end

    it "セッションが消えていれば（ログアウト後は）引けない" do
      token = session.access_token
      session.destroy!

      expect(described_class.find_by_access_token(token)).to be_nil
    end

    it "改ざん・でたらめなトークンでは引けない" do
      expect(described_class.find_by_access_token("#{session.access_token}x")).to be_nil
      expect(described_class.find_by_access_token("garbage")).to be_nil
    end

    it "空・nilでは引けない" do
      expect(described_class.find_by_access_token("")).to be_nil
      expect(described_class.find_by_access_token(nil)).to be_nil
    end

    it "セッションのid（署名なし）そのものでは引けない" do
      expect(described_class.find_by_access_token(session.id)).to be_nil
    end
  end

  describe ".find_by_refresh_token" do
    let(:session) { described_class.start_for(user) }

    it "リフレッシュトークンからセッションを引ける" do
      expect(described_class.find_by_refresh_token(session.refresh_token)).to eq(session)
    end

    it "期限切れのリフレッシュトークンでは引けない" do
      token = session.refresh_token

      travel(AuthSession::REFRESH_TOKEN_TTL + 1.second) do
        expect(described_class.find_by_refresh_token(token)).to be_nil
      end
    end

    it "でたらめ・空・nil・ダイジェストそのものでは引けない" do
      expect(described_class.find_by_refresh_token("garbage")).to be_nil
      expect(described_class.find_by_refresh_token("")).to be_nil
      expect(described_class.find_by_refresh_token(nil)).to be_nil
      expect(described_class.find_by_refresh_token(session.refresh_token_digest)).to be_nil
    end
  end

  describe ".revoke_by_reused_refresh_token" do
    let!(:session) { described_class.start_for(user) }

    it "入れ替え済みの古いリフレッシュトークンが使われたら、そのセッションを消す（盗用とみなす）" do
      old_token = session.refresh_token
      session.rotate_refresh_token!

      expect(described_class.revoke_by_reused_refresh_token(old_token)).to be(true)
      expect(described_class.exists?(session.id)).to be(false)
    end

    it "でたらめ・空・nilのトークンでは何も消さず、falseを返す" do
      session.rotate_refresh_token!

      expect(described_class.revoke_by_reused_refresh_token("garbage")).to be(false)
      expect(described_class.revoke_by_reused_refresh_token("")).to be(false)
      expect(described_class.revoke_by_reused_refresh_token(nil)).to be(false)
      expect(described_class.exists?(session.id)).to be(true)
    end

    it "いま有効なリフレッシュトークンでは消さない" do
      expect(described_class.revoke_by_reused_refresh_token(session.refresh_token)).to be(false)
      expect(described_class.exists?(session.id)).to be(true)
    end
  end

  describe "#rotate_refresh_token!" do
    let!(:session) { described_class.start_for(user) }

    it "リフレッシュトークンを入れ替え、古いトークンでは引けなくなる" do
      old_token = session.refresh_token

      expect(session.rotate_refresh_token!).to be(true)

      expect(session.refresh_token).not_to eq(old_token)
      expect(described_class.find_by_refresh_token(old_token)).to be_nil
      expect(described_class.find_by_refresh_token(session.refresh_token)).to eq(session)
    end

    it "入れ替えた後、メモリ上のレコードに未保存の変更を残さない（後でsaveされても入れ替えを上書きしない）" do
      session.rotate_refresh_token!

      expect(session).not_to be_changed
      expect(session.updated_at).to eq(session.reload.updated_at)
    end

    it "入れ替える前のトークンのダイジェストを、再利用の検知用に残す" do
      old_token = session.refresh_token

      session.rotate_refresh_token!

      expect(session.reload.previous_refresh_token_digest).to eq(Digest::SHA256.hexdigest(old_token))
    end

    it "有効期限を入れ替えた時点から#{AuthSession::REFRESH_TOKEN_TTL.inspect}後に延ばす" do
      travel(1.day) do
        session.rotate_refresh_token!

        expect(session.reload.refresh_token_expires_at).to be_within(1.second).of(AuthSession::REFRESH_TOKEN_TTL.from_now)
      end
    end

    it "同じトークンで同時に更新され、先を越された場合はfalseを返し、入れ替えない" do
      # 同じリフレッシュトークンで2つのリクエストがほぼ同時に来た状況
      other_request = described_class.find(session.id)
      other_request.rotate_refresh_token!

      expect(session.rotate_refresh_token!).to be(false)
      expect(described_class.find_by_refresh_token(other_request.refresh_token)).to eq(session)
    end
  end
end
