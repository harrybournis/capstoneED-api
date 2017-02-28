module JWTAuth
  ## Used in JWTAuthenticator
  class ValidatedRequest
    def initialize(request)
      @csrf_token    = request.headers['X-XSRF-TOKEN']
      @access_token  = request.cookies['access-token']
      @refresh_token = request.cookies['refresh-token']
    end

    attr_reader :csrf_token, :access_token, :refresh_token
  end
end
