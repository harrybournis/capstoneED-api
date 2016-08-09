module JWTAuthenticator2

	# Class Variables
	@@secret		= "secret" 			## TO be replaced with the application's secret key
	@@algorithm 	= "HS256"			# available algorithms: https://github.com/jwt/ruby-jwt
	@@exp			= 10.minutes.to_i	# expiration time for access-token
	@@refresh_exp	= 1.week.to_i		# expiration time for refresh-token
	@@leeway		= 1.week.to_i		# In SECONDS. grace period after a token has expired.
	@@domain  		= "localhost:3000"	# To be added to the cookies
	@@issuer		= @@domain			# typically the website url


	def validate_request(request)
		if request
			require 'pry'
			binding.pry
		else
			return true
		end
	end

	def maimou
		return false
	end

	def self.refresh_exp
		@@refresh_exp
	end

end
