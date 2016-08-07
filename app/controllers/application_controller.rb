class ApplicationController < ActionController::API
	before_action :authenticate_user!

protected
	def authenticate_user!
		JWTAuthenticator.authenticate(request)
	end

end
