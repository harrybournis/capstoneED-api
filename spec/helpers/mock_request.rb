class MockRequest

	#include JWTAuth::JWTAuthenticator

	attr_reader :headers, :cookies, :body

	def initialize(valid, user = nil, device = nil, remember_me = true)
		valid ? valid_request(user, device, remember_me) : invalid_request_hardcoded
	end


private

	def valid_request(set_user = nil, set_device = nil, remember_me = true)
		csrf = "NIBzka/3Plj8yg30+uYnyEBGunKPMhvG8ThF7EJxrBs="
		time = Time.now
		if set_user
			user = set_user
		else
			user = FactoryBot.create(:user)
		end

		if set_device
			device = set_device
		else
			device = SecureRandom.base64(32)
		end

		access_token  = JWTAuth::JWTAuthenticator.encode_token(user, time, csrf, device)
		refresh_token = JWTAuth::JWTAuthenticator.encode_token(user, time, nil, device, remember_me)

		@headers = { "X-XSRF-TOKEN"  => csrf }
		@cookies = { "access-token"  => access_token, #"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMwNDg2MjA1MzYsImp0aSI6Imk3c3FlRVNFREpIVVNCWmQ0SEpONDJvMSIsImlzcyI6ImxvY2FsaG9zdDozMDAwIiwiY3NyZl90b2tlbiI6Ik5JQnprYS8zUGxqOHlnMzArdVlueUVCR3VuS1BNaHZHOFRoRjdFSnhyQnM9In0.HHs3KKfsxkxdcSzeafU1FiXXMfeiomJehdfK9vlKTHQ",
					 "refresh-token" => refresh_token } #"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMwODAxNTY4MTYsImp0aSI6Imk3c3FlRVNFREpIVVNCWmQ0SEpONDJvMSIsImlzcyI6ImxvY2FsaG9zdDozMDAwIn0.RFmIcEVA9-ANLgDSiCPfOYTnGFfnL-YcKVeJPqrE6L0" }
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
end
