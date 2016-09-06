class V1::AuthenticationsController < ApplicationController

	skip_before_action :authenticate_user_jwt, only: [:sign_in_email, :refresh]

	include JWTAuth::JWTAuthenticator

	# GET /me
	# validates the JWT access-token and returns the current user
	def me
		render json: current_user.load, status: :ok
	end

	# POST /refresh
	# creates a new JWT access-token using the refresh-token
	def refresh
		render json: '', status: JWTAuth::JWTAuthenticator.refresh(request, response, cookies) ? :no_content : :unauthorized
	end


	# POST /sign_in
	# Sign in by email and password. Required email and password.
	def sign_in_email
		@user = User.validate_for_sign_in(auth_params)

		if @user.errors.empty?
			if JWTAuth::JWTAuthenticator.sign_in(@user, response, cookies)
				render json: @user, status: :ok
				return
			end
		end
		render json: format_errors(@user.errors), status: :unauthorized
	end


	# DELETE /sign_out
	# Signs out user by deleting the ActiveToken for their device, and deleting the access-token
	# and refresh token cookies
	def sign_out
		if active_token = ActiveToken.find_by_device(current_user.current_device)
			active_token.destroy
		end
		cookies.delete('access-token', domain: JWTAuth::JWTAuthenticator.domain)
		cookies['refresh-token'] = { value: nil, expires: Time.at(0), domain: JWTAuth::JWTAuthenticator.domain, path: '/v1/refresh', secure: true, httponly: true, same_site: true }
		cookies.delete('refresh-token', domain: JWTAuth::JWTAuthenticator.domain, path: '/v1/refresh')
		render json: '', status: :no_content
	end


	# # POST
	# def facebook
	# 	###### REFACTOR
	# 	client = OAuth2::Client.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET'], site: 'https://graph.facebook.com/v2.7', token_url: "/oauth/access_token")

	# 	client.auth_code.authorize_url(:redirect_uri => 'http://localhost:3000/')

	# 	token = client.auth_code.get_token(params[:authentication][:code], redirect_uri: "http://localhost:3000/", parse: :query)
	# 	facebook_response = token.get('/me', :params => { fields: 'id,first_name,last_name,email' })

	# 	user_info = JSON.parse(facebook_response.body)

	# 	user_info.delete("id")

	# 	@user = User.new(user_info)
	# 	@user.provider = 'facebook'
	# 	if @user.save
	# 		render json: @user, status: JWTAuthenticator.sign_in(response, @user) ? :created : :unprocessable_entity
	# 	else
	# 		render json: @user.errors, status: :unprocessable_entity
	# 	end
	# end

	# # POST
	# def google
	# 	# validate user's credentials with oauth2
	# 	#render json: @user, status: JWTAuthenticator.sign_in(response, @user) ? :created : :unprocessable_entity
	# end

private

	def auth_params
		params.permit(:email, :password)
	end

end
