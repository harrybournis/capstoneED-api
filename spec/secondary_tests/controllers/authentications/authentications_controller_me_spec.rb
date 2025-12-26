require 'rails_helper'
require 'helpers/mock_request.rb'
include JwtAuth::JwtAuthenticator

RSpec.describe 'V1::AuthenticationsController GET /me', type: :request do
  context 'valid request' do
    let(:user) { create(:lecturer_confirmed) }
    let(:csrf) { sign_in(user) }
    let(:headers) do
      { 'X-XSRF-TOKEN' => csrf }
    end

    describe 'GET me' do
      it 'should return the user in the token in the response body' do
        get '/v1/me', headers: headers.merge('Include' => 'true')
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        user_in_response = User.find(response_body['user']['id'])

        user_in_token = User.find(JwtAuth::JwtAuthenticator.decode_token(cookies['access-token']).first['id'])
        expect(user_in_token).to be_truthy
        expect(user_in_token.id).to eq(user_in_response.id)
      end

      it 'expect current_user to be same class as their type' do
        get '/v1/me', headers: headers
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['user']['type']).to eq('Lecturer')
      end

      it 'generate for docs lecturer', { docs?: true } do
        get '/v1/me', headers: headers
        expect(status).to eq(200)
      end

      context 'generate for docs student' do
        let(:user) { create(:student_confirmed) }

        it 'generates', { docs?: true, lecturer?: false } do
          get '/v1/me', headers: headers
          expect(status).to eq(200)
        end
      end

      context 'when contains the students xp '  do
        let(:user) do
          student = create :student_confirmed
          sp = student.student_profile
          sp.total_xp = 100
          sp.calculate_level
          sp.save
          student
        end

        it 'contains the students xp' do
          get '/v1/me', headers: headers

          expect(status).to eq(200)
          expect(body['user']['xp']).to be_truthy
          expect(body['user']['xp']['total_xp']).to eq user.total_xp
          expect(body['user']['xp']['level']).to eq user.level
        end
      end

      context "lecturer contains the user's avatar_url" do
        let(:user) { create(:lecturer_confirmed) }

        it "lecturer contains the user's avatar_url" do
          get '/v1/me', headers: headers
          expect(body['user']['avatar_url']).to eq user.avatar_url
        end
      end

      context "student contains the user's avatar_url" do
        let(:user) { create(:student_confirmed) }

        it "student contains the user's avatar_url" do
          get '/v1/me', headers: headers
          expect(body['user']['avatar_url']).to eq user.avatar_url
        end
      end
    end
  end

  context 'invalid request' do
    describe 'GET me' do
      it 'should return 401 without access-token' do
        get '/v1/me', headers: { 'X-XSRF-TOKEN' => SecureRandom.base64(32) }
        expect(response.status).to eq(401)
        expect(cookies['access-token']).to be_falsy
      end

      it 'should return 401 without X-XSRF-TOKEN' do
        mock_request = MockRequest.new(valid = true)
        cookies['access-token'] = mock_request.cookies['access-token']
        get '/v1/me', headers: {}
        expect(response.status).to eq(401)
      end

      it 'should return 401 for invalid access-token' do
        mock_request = MockRequest.new(valid = false)
        cookies['access-token'] = mock_request.cookies['access-token']
        get '/v1/me', headers: {'X-XSRF-TOKEN' => mock_request.headers['X-XSRF-TOKEN']}
        expect(response.status).to eq(401)
      end
    end
  end
end
