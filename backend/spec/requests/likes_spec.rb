require 'rails_helper'

RSpec.describe 'Api::V1::Likes', type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { user.create_new_auth_token }
  let(:spot) { create(:spot) }
  let(:spot_review) { create(:spot_review, spot: spot) }

  describe 'POST /api/v1/spot_reviews/:id/likes' do
    context '認証済みユーザー' do
      context 'まだいいねしていない場合' do
        it '201を返し、likes_countを含む' do
          post "/api/v1/spot_reviews/#{spot_review.id}/likes", headers: auth_headers
          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)['likes_count']).to eq(1)
        end

        it 'Likeレコードが作成される' do
          expect {
            post "/api/v1/spot_reviews/#{spot_review.id}/likes", headers: auth_headers
          }.to change(Like, :count).by(1)
        end
      end

      context 'すでにいいね済みの場合' do
        before { create(:like, user: user, spot_review: spot_review) }

        it '409を返す' do
          post "/api/v1/spot_reviews/#{spot_review.id}/likes", headers: auth_headers
          expect(response).to have_http_status(:conflict)
        end
      end

      context '口コミが存在しない場合' do
        it '404を返す' do
          post '/api/v1/spot_reviews/0/likes', headers: auth_headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context '未認証' do
      it '401を返す' do
        post "/api/v1/spot_reviews/#{spot_review.id}/likes"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/spot_reviews/:id/likes' do
    context '認証済みユーザー' do
      context 'いいね済みの場合' do
        before { create(:like, user: user, spot_review: spot_review) }

        it '204を返す' do
          delete "/api/v1/spot_reviews/#{spot_review.id}/likes", headers: auth_headers
          expect(response).to have_http_status(:no_content)
        end

        it 'Likeレコードが削除される' do
          expect {
            delete "/api/v1/spot_reviews/#{spot_review.id}/likes", headers: auth_headers
          }.to change(Like, :count).by(-1)
        end
      end

      context 'いいねしていない場合' do
        it '404を返す' do
          delete "/api/v1/spot_reviews/#{spot_review.id}/likes", headers: auth_headers
          expect(response).to have_http_status(:not_found)
        end
      end

      context '口コミが存在しない場合' do
        it '404を返す' do
          delete '/api/v1/spot_reviews/0/likes', headers: auth_headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context '未認証' do
      it '401を返す' do
        delete "/api/v1/spot_reviews/#{spot_review.id}/likes"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
