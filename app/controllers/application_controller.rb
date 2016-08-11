class ApplicationController < ActionController::API
	include ActionController::Cookies
	include JWTAuth::JWTAuthenticator

	before_action :authenticate_user


protected

	def authenticate_user
		render json: :none, status: :unauthorized unless JWTAuth::JWTAuthenticator.authenticate(request)
	end

end
