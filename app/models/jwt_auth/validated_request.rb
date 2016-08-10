class JWTAuth::ValidatedRequest

	def initialize(request)
		@csrf_token    = request.headers['X-XSRF-TOKEN']
		@access_token  = request.cookies['access-token']
	end

	def self.new_refresh (request)
		self.new
		@csrf_token    = request.headers['X-XSRF-TOKEN']
		@access_token  = request.cookies['access-token']
		@refresh_token = request.cookies['refresh-token']
	end

	attr_reader :csrf_token, :access_token, :refresh_token

	def csrf_token
		@csrf_token
	end

	def access_token
		@access_token
	end
end
