require 'rails_helper'

RSpec.describe JWTAuth::CurrentUser, type: :model do

	it '.new a new object should be created without database queries' do
		request = MockRequest.new(valid = true)
		token_jti = JWTAuthenticator.decode_token(request.cookies['access-token']).first['jti']
		expect { CurrentUser.new(token_jti) }.to_not make_database_queries
	end

	it '.load_user should return a user found from the jti' do
		user = FactoryGirl.create(:user)
		request = MockRequest.new(valid = true, user)
		token_jti = JWTAuthenticator.decode_token(request.cookies['access-token']).first['jti']
		expect { CurrentUser.new(token_jti) }.to_not make_database_queries

		current_user_obj = CurrentUser.new(token_jti)

		expect(current_user_obj.load_user).to eq(user)
	end

	it '.load_user should not hit the database twice for subsequent calls' do
		user = FactoryGirl.create(:user)
		request = MockRequest.new(valid = true, user)
		token_jti = JWTAuthenticator.decode_token(request.cookies['access-token']).first['jti']
		expect { CurrentUser.new(token_jti) }.to_not make_database_queries

		current_user_obj = CurrentUser.new(token_jti)

		expect { current_user_obj.load_user }.to make_database_queries(count: 1)
		expect { current_user_obj.load_user }.to_not make_database_queries
	end

	it "should respond to the user's methods" do
		user = FactoryGirl.create(:user)
		request = MockRequest.new(valid = true, user)
		token_jti = JWTAuthenticator.decode_token(request.cookies['access-token']).first['jti']
		current_user_obj = CurrentUser.new(token_jti)

		expect { current_user_obj.load_user }.to make_database_queries(count: 1)
		expect { current_user_obj.load_user }.to_not make_database_queries
		expect { current_user_obj.load_user.first_name }.to_not make_database_queries
		expect { current_user_obj.load_user.full_name }.to_not make_database_queries
	end

end

