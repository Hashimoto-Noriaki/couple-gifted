require 'rails_helper'

RSpec.describe 'Spots', type: :request do
  shared_examples '200を返しdataを含む' do
    it { expect(response).to have_http_status(:ok) }
    it { expect(JSON.parse(response.body)).to have_key('data') }
  end

  describe 'GET /api/v1/spots（スポット一覧）' do
    let!(:spot1) { create(:spot, name: '渋谷スポット', address: '東京都渋谷区') }
    let!(:spot2) { create(:spot, name: '新宿スポット', address: '東京都新宿区') }

    context 'パラメータなしの場合' do
      before { get '/api/v1/spots' }

      include_examples '200を返しdataを含む'

      it '全スポットを返す' do
        expect(JSON.parse(response.body)['data'].length).to eq(2)
      end
    end

    context 'エリアで絞り込む場合' do
      before { get '/api/v1/spots', params: { area: '渋谷' } }

      include_examples '200を返しdataを含む'

      it 'addressに一致するスポットのみ返す' do
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['attributes']['name']).to eq('渋谷スポット')
      end
    end

    context 'タグで絞り込む場合' do
      let!(:tag) { create(:tag, name: 'TagDate') }
      let!(:spot_tag) { create(:spot_tag, spot: spot1, tag: tag) }

      before { get '/api/v1/spots', params: { tag: 'TagDate' } }

      include_examples '200を返しdataを含む'

      it 'タグに紐づくスポットのみ返す' do
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['attributes']['name']).to eq('渋谷スポット')
      end
    end
  end

  describe 'GET /api/v1/spots/:id（スポット詳細）' do
    let!(:spot) { create(:spot) }

    context '存在するスポットの場合' do
      before { get "/api/v1/spots/#{spot.id}" }

      include_examples '200を返しdataを含む'

      it 'スポット詳細を返す' do
        json = JSON.parse(response.body)
        expect(json['data']['id']).to eq(spot.id.to_s)
        expect(json['data']['attributes']['name']).to eq(spot.name)
        expect(json['data']['attributes']['address']).to eq(spot.address)
      end
    end

    context '存在しないスポットの場合' do
      before { get '/api/v1/spots/0' }

      it '404を返す' do
        expect(response).to have_http_status(:not_found)
      end

      it 'エラーメッセージを返す' do
        json = JSON.parse(response.body)
        expect(json).to have_key('error')
      end
    end
  end
end
