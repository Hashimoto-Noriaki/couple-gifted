require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  describe 'POST /auth（ユーザー登録）' do
    let(:valid_params) do
      {
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        nickname: 'テストユーザー',
        gender: 'male',
        relationship_status: 'dating'
      }
    end

    context '正常なパラメータの場合' do
      it '登録に成功し、ユーザー情報が返る' do
        post '/auth', params: valid_params
        expect(response).to have_http_status(:ok), response.body
        json = JSON.parse(response.body)
        expect(json['data']['email']).to eq('test@example.com')
        expect(json['data']['nickname']).to eq('テストユーザー')
      end
    end

    shared_examples '必須項目不足で422を返す' do |missing_key|
      it "#{missing_key} がないと登録に失敗する" do
        post '/auth', params: valid_params.except(missing_key)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context '必須項目が欠けている場合' do
      %i[nickname gender relationship_status].each do |missing_key|
        include_examples '必須項目不足で422を返す', missing_key
      end
    end
  end

  describe 'POST /auth/sign_in（ログイン）' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context '正しい認証情報の場合' do
      it 'ログインに成功し、認証ヘッダーが返る' do
        post '/auth/sign_in', params: { email: 'test@example.com', password: 'password123' }
        expect(response).to have_http_status(:ok)
        expect(response.headers['access-token']).to be_present
        expect(response.headers['client']).to be_present
        expect(response.headers['uid']).to be_present
      end
    end

    context '誤った認証情報の場合' do
      it 'ログインに失敗する' do
        post '/auth/sign_in', params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /auth/sign_out（ログアウト）' do
    let(:password) { 'password123' }
    let!(:user) { create(:user, password: password) }
    let(:auth_headers) do
      post '/auth/sign_in', params: { email: user.email, password: password }
      {
        'access-token' => response.headers['access-token'],
        'client'       => response.headers['client'],
        'uid'          => response.headers['uid']
      }
    end

    context '有効な認証ヘッダーの場合' do
      it 'ログアウトに成功する' do
        delete '/auth/sign_out', headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context '無効な認証ヘッダーの場合' do
      it 'ログアウトに失敗する' do
        delete '/auth/sign_out', headers: { 'access-token' => 'invalid', 'client' => 'invalid', 'uid' => 'invalid' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
