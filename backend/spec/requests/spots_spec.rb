require 'rails_helper'

RSpec.describe 'Spots', type: :request do
  describe 'GET /api/v1/spots（スポット一覧）' do
    let!(:spot1) { create(:spot, name: '渋谷スポット', address: '東京都渋谷区') }
    let!(:spot2) { create(:spot, name: '新宿スポット', address: '東京都新宿区') }

    context 'パラメータなしの場合' do
      it '全スポットを返す' do
        get '/api/v1/spots'
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(2)
      end
    end

    context 'エリアで絞り込む場合' do
      it 'addressに一致するスポットのみ返す' do
        get '/api/v1/spots', params: { area: '渋谷' }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['attributes']['name']).to eq('渋谷スポット')
      end
    end

    context 'タグで絞り込む場合' do
      let!(:tag) { create(:tag, name: 'TagDate') }
      let!(:spot_tag) { create(:spot_tag, spot: spot1, tag: tag) }

      it 'タグに紐づくスポットのみ返す' do
        get '/api/v1/spots', params: { tag: 'TagDate' }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['attributes']['name']).to eq('渋谷スポット')
      end
    end
  end

  describe 'GET /api/v1/spots/:id（スポット詳細）' do
    let!(:spot) { create(:spot) }

    context '存在するスポットの場合' do
      it 'スポット詳細を返す' do
        get "/api/v1/spots/#{spot.id}"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['id']).to eq(spot.id.to_s)
        expect(json['data']['attributes']['name']).to eq(spot.name)
        expect(json['data']['attributes']['address']).to eq(spot.address)
      end
    end

    context '存在しないスポットの場合' do
      it '404を返す' do
        get '/api/v1/spots/0'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
