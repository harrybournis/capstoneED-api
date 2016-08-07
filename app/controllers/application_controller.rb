class ApplicationController < ActionController::API
	include JWTAuthenticator

	before_action :authenticate_user


protected

	def authenticate_user
		unless JWTAuthenticator.authenticate(request, response)
			render json: :none, status: :unauthorized
		end
	end

end
