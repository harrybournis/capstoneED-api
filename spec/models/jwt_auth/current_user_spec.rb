require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe JWTAuth::CurrentUser, type: :model do
	CurrentUserLecturer = JWTAuth::CurrentUserLecturer

	context 'testing with User class' do

		before(:each) do
			@user = FactoryGirl.create(:student)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuthenticator.decode_token(@request.cookies['access-token'])
			@token_id = decoded_token.first['id']
			@device = decoded_token.first['device']
			@current_user_obj = CurrentUserStudent.new(@token_id, 'Student', @device)
		end

		it '.new a new object should be created without database queries' do
			expect { CurrentUserStudent.new(@token_id, nil, @device) }.to_not make_database_queries
		end

		it '.load should return a user found from the token id' do
			expect(@current_user_obj.load).to eq(@user)
		end

		it '.load should not hit the database twice for subsequent calls' do
			expect { @current_user_obj.load }.to make_database_queries(count: 1)
			expect { @current_user_obj.load }.to_not make_database_queries
		end

		it "should respond to the user's methods" do
			expect { @current_user_obj.load }.to make_database_queries(count: 1)
			expect { @current_user_obj.load }.to_not make_database_queries
			expect { @current_user_obj.load.first_name }.to_not make_database_queries
			expect { @current_user_obj.load.full_name }.to_not make_database_queries
		end

		it 'should return the id without hitting the database' do
			expect { @current_user_obj.id }.to_not make_database_queries
			expect(@current_user_obj.id).to eq(@user.id)
		end

		it 'should delegate other methods to the user object' do
			expect { @current_user_obj.last_name }.to make_database_queries(count: 1)
			expect { @current_user_obj.last_name }.to_not make_database_queries
			expect(@current_user_obj.last_name).to eq(@user.last_name)
		end

		it '.current_device should equal the device in token' do
			expect { @current_user_obj.current_device }.to_not make_database_queries
			decoded_token = JWTAuthenticator.decode_token(@request.cookies['access-token'])
			expect(@current_user_obj.current_device).to eq(decoded_token.first['device'])
		end
	end

	context 'testing with Student class' do

		before(:each) do
			@user = FactoryGirl.create(:student)
			@request = MockRequest.new(valid = true, @user)
			decoded_token = JWTAuthenticator.decode_token(@request.cookies['access-token']).first
			@token_id = decoded_token['id']
			@device = decoded_token['device']
			@type = decoded_token['type']
			@current_user_obj = CurrentUserStudent.new(@token_id, @type, @device)
		end

		it 'should return the type without hitting the database' do
			expect { @current_user_obj.type }.to_not make_database_queries
			expect(@current_user_obj.type).to eq('Student')

			expect(@current_user_obj.load.class.name).to eq('Student')
		end

	end
end
