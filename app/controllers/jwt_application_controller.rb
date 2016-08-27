class JWTApplicationController < ActionController::API
	include ActionController::Cookies, JWTAuth::JWTAuthenticator, UrlHelper, ApiHelper

	before_action :authenticate_user_jwt

protected

	# Authenticates the user using the access-token in the requres cookies.
	# If authentication is successful, a CurrentUser object containing the
	# actual Student or Lecturer object is assigned as current_user
	def authenticate_user_jwt
		unless @current = JWTAuth::JWTAuthenticator.authenticate(request)
			render json: '', status: :unauthorized
		end
	end

	# Returns a CurrentUser object, which responds to all the methods of a user.
	# Calling current_user.id, current_user.type or current_user.current_device
	# will return the values of the actual Student or Lecturer object without making
	# any database queries. By calling current_user.load, the actual Student or
	# Lecturer object is returned.
	def current_user
		@current
	end

	def user_signed_in?
		!@current.nil?
	end

	def allow_if_authenticated_by_email
		unless @current.provider == 'email'
			render json: format_errors({ provider: "is #{@current.provider}. Did not authenticate with email/password." }), status: :forbidden
		end
	end

	def allow_if_lecturer
		unless @current.load.instance_of? Lecturer
			render json: format_errors({ type: ['must be Lecturer'] }), status: :forbidden
		end
	end

	def allow_if_student
		unless @current.load.instance_of? Student
			render json: format_errors({ type: ['must be Student'] }), status: :forbidden
		end
	end
end
