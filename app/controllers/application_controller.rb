class ApplicationController < ActionController::API
	include JWTAuthenticator

	before_action :authenticate_user


protected

	def authenticate_user
		# unless JWTAuthenticator2.authenticate(request, response)
		# 	render json: :none, status: :unauthorized
		# end
		unless JWTAuthenticator2.validate_request(request).maimou
			render json: :none, status: :unauthorized
		end
	end

end
