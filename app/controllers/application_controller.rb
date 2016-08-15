class ApplicationController < ActionController::API
	include ActionController::Cookies
	include JWTAuth::JWTAuthenticator

	before_action :authenticate_user

protected

	def authenticate_user
		if user_uid = JWTAuth::JWTAuthenticator.authenticate(request)
			@current = JWTAuth::CurrentUser.new(user_uid)
 		else
			render json: :none, status: :unauthorized
		end
	end


	def current_user!
		@current.load_user
	end

end
