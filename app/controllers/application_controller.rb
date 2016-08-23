class ApplicationController < ActionController::API
	include ActionController::Cookies, JWTAuth::JWTAuthenticator, UrlHelper

	before_action :authenticate_user_jwt

protected

	def authenticate_user_jwt
		unless @current = JWTAuth::JWTAuthenticator.authenticate(request)
			render json: '', status: :unauthorized
		end
	end


	def current_user!
		@current
	end


	def authorize_user
		if current_user!.id.to_s == user_params[:id]
			@user = current_user!.load
		else
			render json: { errors:
				{ user: ["User with id #{user_params[:id]} is not authorized to access this resourse." ]} },
				status: :forbidden
		end
	end


	# def only_email_authenticated_users
	# end

end
