require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  describe 'GET /api/v1/tags（タグ一覧）' do
    let!(:tag1) { create(:tag, name: '記念日') }
    let!(:tag2) { create(:tag, name: '初デート') }

    before { get '/api/v1/tags' }

    it '200を返す' do
      expect(response).to have_http_status(:ok)
    end

    it 'dataを含む' do
      expect(JSON.parse(response.body)).to have_key('data')
    end

    it '全タグを返す' do
      expect(JSON.parse(response.body)['data'].length).to eq(2)
    end

    it 'name属性を含む' do
      names = JSON.parse(response.body)['data'].map { |tag| tag['attributes']['name'] }
      expect(names).to contain_exactly('記念日', '初デート')
    end

    context 'タグが存在しない場合' do
      before do
        Tag.delete_all
        get '/api/v1/tags'
      end

      it '空配列を返す' do
        expect(JSON.parse(response.body)['data']).to eq([])
      end
    end
  end
end
