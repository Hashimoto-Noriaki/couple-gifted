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
  end
end
