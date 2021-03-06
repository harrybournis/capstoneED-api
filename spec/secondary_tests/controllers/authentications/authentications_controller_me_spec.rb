require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe 'V1::AuthenticationsController GET /me', type: :controller do

  before(:all) do
    @controller = V1::AuthenticationsController.new
  end

  context 'valid request' do

    describe 'GET me' do

      before(:each) do
        new_en = FactoryGirl.create(:user)
        mock_request = MockRequest.new(valid = true, new_en)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
        expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
        expect(request.headers['X-XSRF-TOKEN']).to be_truthy
      end

      it 'should return the user in the token in the response body' do
        request.headers['Include'] = 'true'
        expect { get :me }.to make_database_queries
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        user_in_response = User.find(response_body['user']['id'])

        user_in_token = User.find(JWTAuth::JWTAuthenticator.decode_token(cookies['access-token']).first['id'])
        expect(user_in_token).to be_truthy
        expect(user_in_token.id).to eq(user_in_response.id)
      end

      it 'expect current_user to be same class as their type' do
        new_en = FactoryGirl.create(:student_confirmed)
        mock_request = MockRequest.new(valid = true, new_en)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
        expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy
        expect(request.headers['X-XSRF-TOKEN']).to be_truthy

        get :me
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['user']['type']).to eq('Student')
      end

      it 'generate for docs lecturer', { docs?: true } do
        mock_request = MockRequest.new(valid = true, FactoryGirl.create(:lecturer_confirmed))
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

        get :me
        expect(status).to eq(200)
      end

      it 'generate for docs student', { docs?: true, lecturer?: false } do
        mock_request = MockRequest.new(valid = true, FactoryGirl.create(:student_confirmed))
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

        get :me
        expect(status).to eq(200)
      end

      it 'contains the students xp' do
        student = create :student_confirmed
        sp = student.student_profile
        sp.total_xp = 100
        sp.calculate_level
        sp.save
        mock_request = MockRequest.new(valid = true, student)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

        get :me

        expect(status).to eq(200)
        expect(body['user']['xp']).to be_truthy
        expect(body['user']['xp']['total_xp']).to eq student.total_xp
        expect(body['user']['xp']['level']).to eq student.level
      end

      it "lecturer contains the user's avatar_url" do
        lec = FactoryGirl.create(:lecturer_confirmed)
        mock_request = MockRequest.new(valid = true, lec)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

        get :me

        expect(body['user']['avatar_url']).to eq lec.avatar_url
      end

      it "student contains the user's avatar_url" do
        student = FactoryGirl.create(:student_confirmed)
        mock_request = MockRequest.new(valid = true, student)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

        get :me

        expect(body['user']['avatar_url']).to eq student.avatar_url
      end
    end

  end

  context 'invalid request' do

    describe 'GET me' do

      it 'should return 401 without access-token' do
        expect(request.cookies['access-token']).to be_falsy
        get :me, params: nil, headers: { 'X-XSRF-TOKEN' => SecureRandom.base64(32) }
        expect(response.status).to eq(401)
        expect(cookies['access-token']).to be_falsy
      end

      it 'should return 401 without X-XSRF-TOKEN' do
        mock_request = MockRequest.new(valid = true)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        expect(JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token'])).to be_truthy

        expect(request.cookies['access-token']).to be_truthy
        get :me, params: nil, headers: { }
        expect(response.status).to eq(401)
      end

      it 'should return 401 for invalid access-token' do
        mock_request = MockRequest.new(valid = false)
        request.cookies['access-token'] = mock_request.cookies['access-token']
        request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
        expect { JWTAuth::JWTAuthenticator.decode_token(request.cookies['access-token']) }.to raise_exception(JWT::VerificationError, 'Signature verification raised')

        get :me
        expect(response.status).to eq(401)
      end


    end
  end



end
