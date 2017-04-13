module JWTAuth
  ## Is included in the ApplicationController and adds the ability to
  #  authenticate using JWTs. Public methods are 'authenticate',
  #  'sign_in' and 'refresh'.
  module JWTAuthenticator
    @secret       = 'secret'.freeze ## Replace with secret
    @algorithm    = 'HS256'.freeze  # available algorithms: https://github.com/jwt/ruby-jwt
    @exp          = 1.minutes       # expiration time for access-token
    @refresh_exp  = 1.week          # expiration time for refresh-token
    @leeway       = 0               # grace period after a token has expired.
    @domain       = api_host_url    # to be added to the cookies. left blank for developement in order to work with browsers. Change variable in helpers/url_helper.rb
    @issuer       = @domain         # typically the website url. added to JWT tokens.

    @cookies_secure     = false     # transmit cookies only on https. Set true for deployment.
    @cookies_httponly   = true      # javascript can't read cookies
    @cookies_samesite   = false     # send cookies only if url in address bar matches the current site

    ###
    # Called before an authenticated endpoint in before_action in
    # application_controller. validates the access-token in the cookies,
    # and compares the csrf_token value in the access-token with the
    # X-XSRF-TOKEN in the headers.
    #
    # returns boolean
    #
    def self.authenticate(request)
      return false unless validated_request = valid_access_request(request)

      decoded_token = decode_token(validated_request.access_token)
      token_params  = decoded_token.first

      if validated_request.csrf_token == token_params['csrf_token']

        if token_params['type'] == 'Student'
          JWTAuth::CurrentUserStudent.new(token_params['id'],
                                          'Student'.freeze,
                                          token_params['device'])
        else
          JWTAuth::CurrentUserLecturer.new(token_params['id'],
                                           'Lecturer'.freeze,
                                           token_params['device'])
        end
      end
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
    def self.sign_in(user, response, cookies, remember_me)
      new_device = nil
      loop do
        new_device = SecureRandom.base64(32)
        break unless ActiveToken.where(device: new_device).any?
      end

      time_now = Time.now

      if create_new_tokens(user, response, cookies, new_device, time_now, remember_me)
        new_token = ActiveToken.new(exp: time_now + @refresh_exp,
                                    device: new_device,
                                    user: user)
        if new_token.valid?
          user.active_tokens << new_token
          return true
        end
      end
      false
    end

    ###
    # Called from the /refresh route. Receives a refresh-token in the cookies.
    # creates a new access-token cookie, a new refresh token cookie, and a
    # csrf token which is added both to the payload of the access-token,
    # and the headers of the response, for later comparison.
    #
    # returns boolean
    #
    def self.refresh(request, response, cookies)
      return false unless validated_request = valid_refresh_request(request)

      decoded_token = decode_token(validated_request.refresh_token)

      valid_token   = ActiveToken.find_by_device(decoded_token.first['device'])

      if valid_token && decoded_token.first['exp'] >= valid_token.exp.to_i
        device      = valid_token.device
        time_now    = DateTime.now
        remember_me = decoded_token.first['remember_me']

        cookies.delete('access-token')
        cookies.delete('refresh-token')

        if create_new_tokens(valid_token.user, response, cookies, device, time_now, remember_me)
          return true if valid_token.update(exp: time_now + @refresh_exp)
        end
      end
      false
    rescue
      false
    end


    #### PRIVATE METHODS
    def self.create_new_tokens(user, response, cookies, device, time_now, remember_me)
      csrf_token        = SecureRandom.urlsafe_base64(32)
      exp_time          = time_now + @exp
      refresh_exp_time  = time_now + @refresh_exp

      access_token      = encode_token(user, time_now, csrf_token, device)
      refresh_token     = encode_token(user, time_now, nil, device, remember_me)

      return false unless access_token && refresh_token

      response.headers['XSRF-TOKEN'] = csrf_token

      if Rails.env.production?
        if remember_me
          cookies['access-token'] = { value: access_token, domain: @domain, expires: exp_time, secure: @cookies_secure, httponly: @cookies_httponly, same_site: @cookies_samesite }
          cookies['refresh-token'] = { value: refresh_token, domain: @domain, expires: refresh_exp_time, path: '/v1/refresh', secure: @cookies_secure, httponly: @cookies_httponly, same_site: @cookies_samesite }
        else
          cookies['access-token'] = { value: access_token, domain: @domain, secure: @cookies_secure, httponly: @cookies_httponly, same_site: @cookies_samesite }
          cookies['refresh-token'] = { value: refresh_token, domain: @domain, path: '/v1/refresh', secure: @cookies_secure, httponly: @cookies_httponly, same_site: @cookies_samesite }
        end

      elsif Rails.env.test? # removed path from refresh token to work with rspec
        if remember_me
          cookies['access-token'] = { value: access_token, domain: "api.example.com", expires: exp_time, httponly: true, same_site: true }
          cookies['refresh-token'] = { value: refresh_token, expires: refresh_exp_time, domain: "api.example.com", httponly: true, same_site: true }
        else
          cookies['access-token'] = { value: access_token, domain: "api.example.com", httponly: true, same_site: true }
          cookies['refresh-token'] = { value: refresh_token, domain: "api.example.com", httponly: true, same_site: true }
        end

      else
        if remember_me
          cookies['access-token'] = { value: access_token, expires: exp_time }
          cookies['refresh-token'] = { value: refresh_token, expires: refresh_exp_time, path: '/v1/refresh' }
        else
          cookies['access-token'] = { value: access_token }
          cookies['refresh-token'] = { value: refresh_token, path: '/v1/refresh' }
        end
      end

      true
    end

    def self.encode_token(user, time_now, csrf_token = nil, device_id = nil, remember_me = false)
      if csrf_token
        exp_time = time_now + @exp
        access_token_payload = { exp: exp_time.to_i,
                                 id: user.id,
                                 type: user.type,
                                 iss: @issuer,
                                 device: device_id,
                                 csrf_token: csrf_token }
        JWT.encode(access_token_payload, @secret, @algorithm)
      else
        refresh_exp_time      = time_now + @refresh_exp
        refresh_token_payload = { exp: refresh_exp_time.to_i,
                                  iss: @issuer,
                                  device: device_id,
                                  remember_me: remember_me }
        JWT.encode(refresh_token_payload, @secret, @algorithm)
      end
    end

    def self.decode_token(token)
      if Rails.env.production?
        JWT.decode(token, @secret, true, algorithm: @algorithm,
                                         leeway: @leeway.to_i,
                                         iss: @issuer,
                                         verify_iss: true)
      else
        JWT.decode(token, @secret, true, algorithm: @algorithm,
                                         leeway: @leeway.to_i)
      end
    end

    def self.valid_access_request(request)
      if request.headers['X-XSRF-TOKEN'].nil?
        false
      elsif request.cookies['access-token'].nil?
        false
      else
        JWTAuth::ValidatedRequest.new(request)
      end
    end

    def self.valid_refresh_request(request)
      if request.cookies['refresh-token'].nil?
        false
      else
        JWTAuth::ValidatedRequest.new(request)
      end
    end

    def self.refresh_exp
      @refresh_exp
    end

    def self.domain
      @domain
    end
  end
end
