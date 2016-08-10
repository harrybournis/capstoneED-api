module JWTAuthenticator

	# Class Variables
	@@secret		= "secret" 			## TO be replaced with the application's secret key
	@@algorithm 	= "HS256"			# available algorithms: https://github.com/jwt/ruby-jwt
	@@exp			= 10.minutes.to_i	# expiration time for access-token
	@@refresh_exp	= 1.week.to_i		# expiration time for refresh-token
	@@leeway		= 1.week.to_i		# In SECONDS. grace period after a token has expired.
	@@domain  		= "localhost:3000"	# To be added to the cookies
	@@issuer		= @@domain			# typically the website url


	def self.validate_access_request(request)
		if request.headers["X-XSRF-TOKEN"].nil?
			false
		elsif request.cookies["access-token"].nil?
			false
		else
			true
		end
	end

	def self.validate_refresh_request(request)
		if request.headers["X-XSRF-TOKEN"].nil?
			false
		elsif request.cookies["access-token"].nil? && request.cookies["refresh-token"].nil?
			false
		else
			true
		end
	end

	def self.decode_token (token)
		JWT.decode(token, @@secret, true, { algorithm: @@algorithm,
											leeway: @@leeway,
											iss: @@issuer,
											verify_iss: true
																	})
	end

	def self.encode_token (user, time_now, csrf_token = nil)
		if csrf_token

			exp_time = time_now + @@exp
			access_token_payload = { exp: exp_time.to_i, jti: user.uid, iss: @@issuer, csrf_token: csrf_token }

			JWT.encode(access_token_payload, @@secret, @@algorithm)

		else
			refresh_exp_time = time_now + @@refresh_exp
			refresh_token_payload = { exp: refresh_exp_time.to_i, jti: user.uid, iss: @@issuer }

			JWT.encode(refresh_token_payload, @@secret, @@algorithm)
		end
	end

	def self.refresh_exp
		@@refresh_exp
	end

end
