class MockRequest

	#include JWTAuth::JWTAuthenticator

	attr_reader :headers, :cookies, :body

	def initialize(valid, user = nil, device = nil)
		valid ? valid_request(user, device) : invalid_request_hardcoded
	end


private

	def valid_request(set_user = nil, set_device = nil)
		csrf = "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs="
		time = Time.now
		if set_user
			user = set_user
		else
			user = FactoryGirl.create(:user)
		end

		if set_device
			device = set_device
		else
			device = SecureRandom.base64(32)
		end

		access_token  = JWTAuth::JWTAuthenticator.encode_token(user, time, csrf, nil)
		refresh_token = JWTAuth::JWTAuthenticator.encode_token(user, time, nil, device)

		@headers = { "X-XSRF-TOKEN"  => csrf }
		@cookies = { "access-token"  => access_token, #"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMwNDg2MjA1MzYsImp0aSI6Imk3c3FlRVNFREpIVVNCWmQ0SEpONDJvMSIsImlzcyI6ImxvY2FsaG9zdDozMDAwIiwiY3NyZl90b2tlbiI6Ik5JQnprYS8zUGxqOHlnMzArdVlueUVCR3VuS1BNaHZHOFRoRjdFSnhyQnM9In0.HHs3KKfsxkxdcSzeafU1FiXXMfeiomJehdfK9vlKTHQ",
					 "refresh-token" => refresh_token } #"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMwODAxNTY4MTYsImp0aSI6Imk3c3FlRVNFREpIVVNCWmQ0SEpONDJvMSIsImlzcyI6ImxvY2FsaG9zdDozMDAwIn0.RFmIcEVA9-ANLgDSiCPfOYTnGFfnL-YcKVeJPqrE6L0" }

		@headers.merge!(headers) if headers
		@cookies.merge!(cookies) if cookies
		@body.merge!(body) 		 if body
	end

	def valid_request_hardcoded(set_user = nil, headers=nil, cookies=nil, body=nil)
		csrf = "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs="
		@headers = { "X-XSRF-TOKEN"  => csrf }
		@cookies = { "access-token"  => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMwNDg2MjA1MzYsImp0aSI6Imk3c3FlRVNFREpIVVNCWmQ0SEpONDJvMSIsImlzcyI6ImxvY2FsaG9zdDozMDAwIiwiY3NyZl90b2tlbiI6Ik5JQnprYS8zUGxqOHlnMzArdVlueUVCR3VuS1BNaHZHOFRoRjdFSnhyQnM9In0.HHs3KKfsxkxdcSzeafU1FiXXMfeiomJehdfK9vlKTHQ",
					 "refresh-token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMwODAxNTY4MTYsImp0aSI6Imk3c3FlRVNFREpIVVNCWmQ0SEpONDJvMSIsImlzcyI6ImxvY2FsaG9zdDozMDAwIn0.RFmIcEVA9-ANLgDSiCPfOYTnGFfnL-YcKVeJPqrE6L0" }

		@headers.merge!(headers) if headers
		@cookies.merge!(cookies) if cookies
		@body.merge!(body) 		 if body
	end

	def invalid_request_hardcoded
		@headers = { "X-XSRF-TOKEN"  => "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs=" }
		@cookies = { "access-token"  => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMwNDg2MjA1MzYsImp0aSI6Imk3c3FlRVNFREpIVVNCWmQ0SEpONDJvMSIsImlzcyI6ImFwaS5sb2NhbGhvc3Q6MzAwMCIsImNzcmZfdG9rZW4iOiJOSUJ6a2EvM1Bsajh5ZzMwK3VZbnlFQkd1bktQTWh2RzhUaEY3RUp4ZHJCcz0ifQ.zuAHQrKiKGfK__RzdgqBIh3DBRZZfUziO1SFe0dOnNg",
					 "refresh-token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMwODAxNTY4MTYsImp0aSI6Imk3c3FlRVNFREpIVVNCWmQ0SEpONDJvMSIsImlzcyI6ImFwaS5sb2NhbGhvc3Q6MzAwMCJ9.PNVAiFac58kOJBKAu1KSiyZspj1ij8DOOstQ6Jgj_ns" }

		@headers.merge!(headers) if headers
		@cookies.merge!(cookies) if cookies
		@body.merge!(body) 		 if body
	end

###
# access token:
# {
#   "alg": "HS256",
#   "typ": "JWT"
# }
# {
#   "exp": 3048620536,
#   "jti" : "i7sqeESEDJHUSBZd4HJN42o1",
#   "iss": "localhost:3000",
#   "csrf_token": "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs="
# }
###
#
###
# refresh token:
#{
  # "exp": 3080156816,
  # "jti": "i7sqeESEDJHUSBZd4HJN42o1",
  # "iss": "localhost:3000"
#}
#
end
