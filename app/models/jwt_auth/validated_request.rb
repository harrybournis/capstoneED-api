class JWTAuth::ValidatedRequest

	def initialize(request)
		@csrf_token = nil
		@access_token = nil
		@refresh_token = nil
		@csrf_token    = request.headers['X-XSRF-TOKEN']
		@access_token  = request.cookies['access-token']
		if request.cookies['refresh-token']
			@refresh_token = request.cookies['refresh-token']
		else
			@refresh_token = nil
		end
	end

	attr_reader :csrf_token, :access_token, :refresh_token
end
