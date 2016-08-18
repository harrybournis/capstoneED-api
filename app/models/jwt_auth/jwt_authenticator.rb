module JWTAuth::JWTAuthenticator

	# Class Variables
	@@secret		= 'secret' 				## TO be replaced with the application's secret key
	@@algorithm 	= 'HS256'				# available algorithms: https://github.com/jwt/ruby-jwt
	@@exp			= 10.minutes			# expiration time for access-token
	@@refresh_exp	= 1.week				# expiration time for refresh-token
	@@leeway		= 1.week				# grace period after a token has expired.
	@@domain  		= 'api.localhost:3000' 	# to be added to the cookies
	@@issuer		= @@domain				# typically the website url. added to JWT tokens.


	###
	# Called before an authenticated endpoint in before_action in application_controller.
	# validates the access-token in the cookies, and compares the csrf_token value
	# in the access-token with the X-XSRF-TOKEN in the headers.
	#
	# returns boolean
	#
	def self.authenticate (request)
		return false unless validated_request = valid_access_request(request)

		decoded_token = decode_token(validated_request.access_token)

		validated_request.csrf_token == decoded_token.first['csrf_token'] ? decoded_token.first['jti'] : nil
	rescue
		false
	end

	###
	# Called after successful authentication either by email or oauth2.
	# Creates new access-token cookie, and new refresh-token cookie.
	# Also creates a csrf token which is added both to the payload of the
	# access-token, and the headers of the response, for later comparison.
	#
	# returns boolean
	#
	def self.sign_in (user, response, cookies)
		new_device = nil
		loop do
			new_device = SecureRandom.base64(32)
			break unless ActiveToken.where(device: new_device).any?
		end

		time_now = Time.now

		if create_new_tokens(user, response, cookies, new_device, time_now)
			new_token = ActiveToken.new(exp: time_now + @@refresh_exp, device: new_device, user: user)

			if new_token.valid?
				user.active_tokens << new_token
				return true
			end
		end

		return false
	end

	###
	# Called from the /refresh route. Receives a refresh-token in the cookies.
	# creates a new access-token cookie, a new refresh token cookie, and a csrf token which
	# is added both to the payload of the access-token, and the headers of
	# the response, for later comparison.
	#
	# returns boolean
	#
	def self.refresh (request, response,  cookies)
		return false unless validated_request = valid_refresh_request(request)

		decoded_token = decode_token(validated_request.refresh_token)

		valid_token = ActiveToken.find_by_device(decoded_token.first['device'])

		if valid_token && decoded_token.first['exp'] > valid_token.exp.to_i
			device = valid_token.device
			time_now = DateTime.now

			if create_new_tokens(valid_token.user, response, cookies, device, time_now)
				return true if valid_token.update(exp: time_now + @@refresh_exp)
			end
		end
		false
	rescue
		false
	end


	#### PRIVATE METHODS
	def self.create_new_tokens (user, response, cookies, device, time_now)
		csrf_token			  = SecureRandom.base64(32)
		exp_time 			  = time_now + @@exp
		refresh_exp_time	  = time_now + @@refresh_exp

		access_token 		  = encode_token(user, time_now, csrf_token)
		refresh_token		  = encode_token(user, time_now, nil, device)

		return false unless access_token && refresh_token

		response.headers['XSRF-TOKEN'] = csrf_token
		cookies['access-token'] = { value: access_token, expires: exp_time, domain: @@issuer, secure: true, httponly: true, same_site: true }
		cookies['refresh-token'] = { value: refresh_token, expires: refresh_exp_time, domain: @@issuer, path: '/v1/refresh', secure: true, httponly: true, same_site: true }
		true
	end


	def self.encode_token (user, time_now, csrf_token = nil, device_id = nil)
		if csrf_token
			exp_time = time_now + @@exp
			access_token_payload = { exp: exp_time.to_i, jti: user.uid, iss: @@issuer, csrf_token: csrf_token }

			JWT.encode(access_token_payload, @@secret, @@algorithm)

		else
			refresh_exp_time = time_now + @@refresh_exp
			refresh_token_payload = { exp: refresh_exp_time.to_i, iss: @@issuer, device: device_id }

			JWT.encode(refresh_token_payload, @@secret, @@algorithm)
		end
	end


	def self.decode_token (token)
		JWT.decode(token, @@secret, true, { algorithm: @@algorithm,
											leeway: @@leeway.to_i,
											iss: @@issuer,
											verify_iss: true
																	})
	end


	def self.valid_access_request(request)
		if request.headers['X-XSRF-TOKEN'].nil?
			false
		elsif request.cookies['access-token'].nil?
			false
		else
			return JWTAuth::ValidatedRequest.new(request)
		end
	end


	def self.valid_refresh_request(request)
		if request.cookies['refresh-token'].nil?
			false
		else
			JWTAuth::ValidatedRequest.new(request)
		end
	end


	def self.refresh_exp ; @@refresh_exp end
	def self.domain		 ; @@domain end
end
