module UrlHelper

	# Used @ views/devise/mailer/reset_password_instructions.html.erb
	# Should be the url of the client application that allows the user to reset their password
	def client_reset_password_url(token)
		"https://capstoned.com?reset_password_token=#{token}"
	end

	# Used @ models/jwt_auth/jwt_authenticator.rb
	# Should be the API's host url
	# Left empty for development
	def api_host_url
		""
	end

	# Used @ controllers/v1/confirmations_controller.rb
	# The page to show after a users successfully confirms their account
	def api_confirmation_success_url
		redirect_to '/user_confirmation_success.html'
	end

	# Used @ controllers/v1/confirmations_controller.rb
	# The page to show after a users fails to confirm their account
	def api_confirmation_failure_url
		redirect_to  '/user_confirmation_failure.html'
	end

end
