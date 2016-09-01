class JWTApplicationController < ActionController::API
	include ActionController::Cookies, JWTAuth::JWTAuthenticator, UrlHelper, ApiHelper, CurrentUserHelper

	before_action :authenticate_user_jwt

	protected

		# Authenticates the user using the access-token in the requres cookies.
		# If authentication is successful, a CurrentUser object containing the
		# actual Student or Lecturer object is assigned as current_user
		def authenticate_user_jwt
			unless @current = JWTAuth::JWTAuthenticator.authenticate(request)
				render json: format_errors({ base: 'Authentication Failed' }), status: :unauthorized
			end
		end

end
