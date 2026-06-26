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
end
