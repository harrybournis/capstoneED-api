class ApplicationController < ActionController::API
	include ActionController::Cookies
	include JWTAuth::JWTAuthenticator

	before_action :authenticate_user_jwt

protected

	def authenticate_user_jwt
		if user_id = JWTAuth::JWTAuthenticator.authenticate(request)
			@current = JWTAuth::CurrentUser.new(user_id)
 		else
			render json: :none, status: :unauthorized
		end
	end


	def current_user!
		@current.load_user
	end


	def authorize_user
		if current_user!.id.to_s == user_params[:id]
			@user = current_user!
		else
			render json: :none, status: :forbidden
		end
	end

end
