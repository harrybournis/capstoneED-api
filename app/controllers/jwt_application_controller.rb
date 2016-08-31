class JWTApplicationController < ActionController::API
	include ActionController::Cookies, JWTAuth::JWTAuthenticator, UrlHelper, ApiHelper

	before_action :authenticate_user_jwt

	# Handle any unexpected exceptions. Instead of rendering the deault 404.html or 500.html
	# Respond with json. In case the environment is not production, send the exception as well.
	rescue_from StandardError do |e|
  	render json: format_errors({ base: [Rails.env.production? ? 'Operation Failed' : e.message] }), status: 500
  end


protected


	# Authenticates the user using the access-token in the requres cookies.
	# If authentication is successful, a CurrentUser object containing the
	# actual Student or Lecturer object is assigned as current_user
	def authenticate_user_jwt
		unless @current = JWTAuth::JWTAuthenticator.authenticate(request)
			render json: format_errors({ base: 'Authentication Failed' }), status: :unauthorized
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
			render json: format_errors({ base: "Provider is #{@current.provider}. Did not authenticate with email/password." }), status: :forbidden
		end
	end

	def allow_if_lecturer
		unless @current.load.instance_of? Lecturer
			render json: format_errors({ base: ['You must be Lecturer to access this resource'] }), status: :forbidden
			false
		end
	end

	def allow_if_student
		unless @current.load.instance_of? Student
			render json: format_errors({ base: ['You must be Student to access this resource'] }), status: :forbidden
			false
		end
	end
end
