class MockRequest

	include JWTAuth::JWTAuthenticator

	attr_reader :headers, :cookies, :body

	def initialize(valid, user = nil, args = nil)
		valid ? valid_request(user, args) : invalid_request_hardcoded(args)
	end


private

	def valid_request(set_user = nil, headers=nil, cookies=nil, body=nil)
		csrf = "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs="
		time = Time.now
		user = set_user || FactoryGirl.build(:user)

		access_token  = JWTAuth::JWTAuthenticator.encode_token(user, time, csrf)
		refresh_token = JWTAuth::JWTAuthenticator.encode_token(user, time)

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

	def invalid_request_hardcoded(headers=nil, cookies=nil, body=nil)
		@headers = { "X-XSRF-TOKEN"  => "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs=" }
		@cookies = { "access-token"  => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMwNDg2MjA1MzYsImp0aSI6Imk3c3FlRVNFREpIVVNCWmQ0SEpONDJvMSIsImlzcyI6ImxvY2FsaG9zdDozMDAwIiwiY3NyZl90b2tlbiI6Ik5JQnprYS8zUGxqOHlnMzArdVlueUVCR3VuS1BNaHZHOFRoRjdFSnhkckJzPSJ9.P01mbi5sMnrRr17u79srYfEgkO66eYEK8iFc0n3vIrY",
					 "refresh-token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMwODAxNTY4MTYsImp0aSI6Imk3c3FlRVNFREpIVVNCWmQ0SEpONDJvMSIsImlzcyI6ImxvY2FsaG9zdDozMDAwIn0.COOnUxFFyiWUl6DNbUloGNllh8GFeD8OKgNhQr7HCtA" }

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
