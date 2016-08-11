module JWTAuthenticatorOld

	# Class Variables
	@@secret		= "secret" 			## TO be replaced with the application's secret key
	@@algorithm 	= "HS256"			# available algorithms: https://github.com/jwt/ruby-jwt
	@@exp			= 10.minutes.to_i	# expiration time for access-token
	@@refresh_exp	= 1.week.to_i		# expiration time for refresh-token
	@@leeway		= 1.week.to_i		# In SECONDS. grace period after a token has expired.
	@@domain  		= "localhost:3000"	# To be added to the cookies
	@@issuer		= @@domain			# typically the website url


	###
	# Called before an authenticated endpoint in before_action in application_controller
	# validates the access-token in the cookies, and also
	# compares the csrf_token value in the access-token with the
	# X-XSRF-TOKEN in the headers
	#
	# returns boolean
	#
	def self.authenticate (request, response)

		return validate_access_token_csrf(request, response)

	rescue => e
		Rails.logger.info e.message
		return false
	end

	###
	# called from the authentications_controller after successful authentication
	# either by email or oauth2
	# creates new access-token cookie, and new refresh-token cookie
	# also creates a csrf token which is added both to the payload of the
	# access-token, and the headers of the response, for later comparison.
	#
	# returns boolean
	#
	def self.sign_in (response, user)
		csrf_token			  = SecureRandom.base64(32)
		time_now 			  = Time.now
		exp_time 			  = time_now + @@exp
		refresh_exp_time	  = time_now + @@refresh_exp

		access_token_payload  = { exp: exp_time.to_i,
								 jti: user.uid,
								 iss: @@issuer,
								 csrf_token: csrf_token }
		refresh_token_payload = { exp: refresh_exp_time.to_i, jti: user.uid, iss: @@issuer }

		access_token  = JWT.encode(access_token_payload, @@secret, @@algorithm)
		refresh_token = JWT.encode(refresh_token_payload, @@secret, @@algorithm)

		if access_token && refresh_token
			response.headers["csrf_token"] = csrf_token
			response.headers["Set-Cookie"] = "access-token=#{access_token}; Domain=#{@@issuer}; Expires=#{exp_time.to_datetime}; Secure; HttpOnly; SameSite=Strict" # same site new chrome-firefox feature
			response.headers["Set-Cookie"] = "refresh-token=#{refresh_token}; Domain=#{@@issuer}; Expires=#{refresh_exp_time.to_datetime}; Secure; HttpOnly; SameSite=Strict" # same site new chrome-firefox feature
			return true
		end

		return false
	end


	###
	# called from the authentications_controller's /refresh route,
	# receives an expired access-token, a refresh-token, as well as
	# a X-XSRF-TOKEN in the headers. After the csrf_token in the payload of the
	# expired access-token with the X-XSRF-TOKEN in the headers, the refresh token
	# is validated.
	# creates a new access-token cookie, and creates a csrf token which
	# is added both to the payload of the access-token, and the headers of
	# the response, for later comparison.
	#
	# returns boolean
	#
	def self.refresh (request, response)
		begin
			if validate_access_token_csrf(request, response)
				decoded_refresh_token = decode_token(request.cookies["refresh-token"])
			else
				return false
			end

		rescue JWT::InvalidIssuerError => e
			Rails.logger.info e.message
			return false
		rescue JWT::ExpiredSignature => e
			Rails.logger.info e.message
			# if the exception is Expired Signature keep executing
		rescue => e
			Rails.logger.info e.message
			return false
		end

		# generate new access-token
		csrf_token			  = SecureRandom.base64(32)
		exp_time 			  = Time.now + @@exp

		access_token_payload = { exp: exp_time,
								 jti: decoded_refresh_token.first["jti"],
								 iss: @@issuer,
								 csrf_token: csrf_token }

		access_token  = JWT.encode(access_token_payload, @@secret, @@algorithm)

		if access_token
			response.headers["csrf_token"] = csrf_token
			response.headers["Set-Cookie"] = "access-token=#{access_token}; Domain=#{@@issuer}; Expires=#{exp_time.to_datetime}; Secure; HttpOnly; SameSite=Strict"
			return true
		end

		return false
	end


# private methods
#
	def self.validate_access_token_csrf (request, response)
		csrf_token = request.headers["X-XSRF-TOKEN"]
		unless csrf_token
			Rails.logger.info "CSRF Token Missing from Headers."
			return false
		end

		token = request.cookies["access-token"]
		unless token
			Rails.logger.info "Access Token Missing from Cookies."
			return false
		end

		decoded_token = decode_token(token)

		return csrf_token == decoded_token.first["csrf_token"]
	end


	def self.decode_token (token)
		JWT.decode(token, @@secret, true, { algorithm: @@algorithm,
											leeway: @@leeway,
											iss: @@issuer,
											verify_iss: true
																	})
	end

	def self.refresh_exp
		@@refresh_exp
	end

end
