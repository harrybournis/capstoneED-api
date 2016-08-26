class JWTApplicationController < ActionController::API
	include ActionController::Cookies, JWTAuth::JWTAuthenticator, UrlHelper, ApiHelper

	before_action :authenticate_user_jwt

protected

	def authenticate_user_jwt
		unless @current = JWTAuth::JWTAuthenticator.authenticate(request)
			render json: '', status: :unauthorized
		end
	end


	def current_user
		@current
	end


	# def allow_if_lecturer
	# 	unless @current.type == 'Lecturer'
	# 		render json: format_errors({ type: ['must be Lecturer'] }), status: :forbidden
	# 	end
	# end


	# def allow_if_student
	# 	unless @current.type == 'Student'
	# 		render json: format_errors({ type: ['must be Student'] }), status: :forbidden
	# 	end
	# end


	# def allow_if_authenticated_by_email
	# 	unless @current.provider == 'email'
	# 		render json: format_errors({ provider: ['must be email'] })
	# 	end
	# end

end
