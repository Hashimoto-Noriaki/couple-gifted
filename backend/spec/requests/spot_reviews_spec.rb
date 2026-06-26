require 'rails_helper'

RSpec.describe 'SpotReviews', type: :request do
  describe 'GET /api/v1/spots/:id/spot_reviews（口コミ一覧）' do
    let!(:spot) { create(:spot) }
    let!(:user) { create(:user) }
    let!(:review1) { create(:spot_review, spot: spot, user: user, rating: 5, body: '最高でした') }
    let!(:review2) { create(:spot_review, spot: spot, user: user, rating: 3, body: '普通でした') }

    context '存在するスポットの場合' do
      before { get "/api/v1/spots/#{spot.id}/spot_reviews" }

      it '200を返す' do
        expect(response).to have_http_status(:ok)
      end

      it 'dataを含む' do
        expect(JSON.parse(response.body)).to have_key('data')
      end

      it 'スポットに紐づく口コミをすべて返す' do
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(2)
      end

      it 'rating・body・relationship_status_at_visit・created_at・user_nicknameを含む' do
        json = JSON.parse(response.body)
        attrs = json['data'][0]['attributes']
        expect(attrs).to include('rating', 'body', 'relationship_status_at_visit', 'created_at', 'user_nickname')
      end
    end

    context '存在しないスポットの場合' do
      before { get '/api/v1/spots/0/spot_reviews' }

      it '404を返す' do
        expect(response).to have_http_status(:not_found)
      end

      it 'エラーメッセージを返す' do
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end

    context '別スポットの口コミは含まない' do
      let!(:other_spot) { create(:spot) }
      let!(:other_review) { create(:spot_review, spot: other_spot, user: user) }

      before { get "/api/v1/spots/#{spot.id}/spot_reviews" }

      it '対象スポットの口コミのみ返す' do
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(2)
      end
    end
  end

  describe 'POST /api/v1/spots/:id/spot_reviews（口コミ投稿）' do
    let!(:spot) { create(:spot) }
    let!(:user) { create(:user) }
    let(:auth_headers) { user.create_new_auth_token }
    let(:valid_params) do
      {
        rating: 5,
        body: '最高のデートスポットでした。',
        relationship_status_at_visit: 'dating'
      }
    end

    context '認証済みユーザーが正常なパラメータで投稿した場合' do
      before { post "/api/v1/spots/#{spot.id}/spot_reviews", params: valid_params, headers: auth_headers }

      it '201を返す' do
        expect(response).to have_http_status(:created)
      end

      it 'dataを含む' do
        expect(JSON.parse(response.body)).to have_key('data')
      end

      it '投稿した口コミの内容を返す' do
        json = JSON.parse(response.body)
        attrs = json['data']['attributes']
        expect(attrs['rating']).to eq(5)
        expect(attrs['body']).to eq('最高のデートスポットでした。')
        expect(attrs['relationship_status_at_visit']).to eq('dating')
        expect(attrs['user_nickname']).to eq(user.nickname)
      end

      it 'DBに口コミが1件作成される' do
        expect(SpotReview.count).to eq(1)
      end
    end

    context '未認証の場合' do
      before { post "/api/v1/spots/#{spot.id}/spot_reviews", params: valid_params }

      it '401を返す' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context '存在しないスポットの場合' do
      before { post '/api/v1/spots/0/spot_reviews', params: valid_params, headers: auth_headers }

      it '404を返す' do
        expect(response).to have_http_status(:not_found)
      end

      it 'エラーメッセージを返す' do
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end

    context 'バリデーションエラーの場合' do
      let(:invalid_params) { { rating: 6, body: '', relationship_status_at_visit: 'dating' } }

      before { post "/api/v1/spots/#{spot.id}/spot_reviews", params: invalid_params, headers: auth_headers }

      it '422を返す' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'エラーメッセージを返す' do
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end
  end

  describe 'DELETE /api/v1/spot_reviews/:id（口コミ削除）' do
    let!(:owner) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:spot) { create(:spot) }
    let!(:review) { create(:spot_review, user: owner, spot: spot) }
    let(:owner_headers) { owner.create_new_auth_token }
    let(:other_headers) { other_user.create_new_auth_token }

    context '投稿者本人が削除する場合' do
      before { delete "/api/v1/spot_reviews/#{review.id}", headers: owner_headers }

      it '204を返す' do
        expect(response).to have_http_status(:no_content)
      end

      it 'DBから口コミが削除される' do
        expect(SpotReview.find_by(id: review.id)).to be_nil
      end
    end

    context '他のユーザーが削除しようとした場合' do
      before { delete "/api/v1/spot_reviews/#{review.id}", headers: other_headers }

      it '403を返す' do
        expect(response).to have_http_status(:forbidden)
      end

      it 'エラーメッセージを返す' do
        expect(JSON.parse(response.body)).to have_key('error')
      end

      it 'DBから口コミが削除されない' do
        expect(SpotReview.find_by(id: review.id)).not_to be_nil
      end
    end

    context '未認証の場合' do
      before { delete "/api/v1/spot_reviews/#{review.id}" }

      it '401を返す' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context '存在しない口コミの場合' do
      before { delete '/api/v1/spot_reviews/0', headers: owner_headers }

      it '404を返す' do
        expect(response).to have_http_status(:not_found)
      end

      it 'エラーメッセージを返す' do
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end
  end
end
