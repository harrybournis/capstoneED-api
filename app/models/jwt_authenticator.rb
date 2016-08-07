class JWTAuthenticator
	class << self
		# Called before an authenticated endpoint in before_action
		def authenticate (request)
			require 'pry'
			binding.pry
		end

		# called after successful authentcation in the authentications_controller
		def sign_in (response, user)

		end

		def refresh (request)
		end

	private

	end
end
