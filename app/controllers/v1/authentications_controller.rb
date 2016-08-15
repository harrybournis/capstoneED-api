class V1::AuthenticationsController < ApplicationController

	skip_before_action :authenticate_user, except: [:validate]

	include JWTAuth::JWTAuthenticator


	# validates the JWT access-token
	# GET
	def validate
		render json: request.headers['Include'].present? ? current_user! : :none, status: :ok
	end

	# creates a new JWT access-token using the refresh-token
	# POST
	def refresh
		#render json: :none, status: JWTAuth::JWTAuthenticator.refresh(request,response) ? :ok : :unauthorized
	end

	# POST
	def email
		# validate user's credentials
		#
		##
		@user = User.first
		if JWTAuth::JWTAuthenticator.sign_in(@user, response, cookies)
			render json: @user, status: :ok
		else
			render json: :none, status: :unprocessable_entity
		end
	end

	# POST
	def facebook
		###### REFACTOR
		client = OAuth2::Client.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET'], site: 'https://graph.facebook.com/v2.7', token_url: "/oauth/access_token")

		client.auth_code.authorize_url(:redirect_uri => 'http://localhost:3000/')

		token = client.auth_code.get_token(params[:authentication][:code], redirect_uri: "http://localhost:3000/", parse: :query)
		facebook_response = token.get('/me', :params => { fields: 'id,first_name,last_name,email' })

		user_info = JSON.parse(facebook_response.body)

		user_info.delete("id")

		# # save the user
		#
		# # #
		#render json: @user, status: JWTAuthenticator.sign_in(response, @user) ? :created : :unprocessable_entity
	end

	# POST
	def google
		# validate user's credentials with oauth2
		#render json: @user, status: JWTAuthenticator.sign_in(response, @user) ? :created : :unprocessable_entity
	end
end
