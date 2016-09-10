class ApplicationController < ActionController::API

	include ActionController::Cookies, 	# Add cookie functionality
					JWTAuth::JWTAuthenticator,	# Add the ability to authenticate via JWT tokens
					UrlHelper,									# Url helpers to globally change URL's for emails or redirects
					ApiHelper,									# Methods that provide a common behavior for the API (e.g. error rendering)
					CurrentUserable,						# Current User helper methods, including validations
					AssociationIncludable				# Logic for allowing the user to pass ?inlcudes= in the params, and autoload the associated records.

	before_action :authenticate_user_jwt

	protected

		# Authenticates the user using the access-token in the requres cookies.
		# If authentication is successful, a CurrentUser object containing the
		# actual Student or Lecturer object is assigned as current_user
		def authenticate_user_jwt
			unless @current = JWTAuth::JWTAuthenticator.authenticate(request)
				render json: format_errors({ base: 'Authentication Failed' }), status: :unauthorized
			end
		end

		# Handle any unexpected exceptions. Instead of rendering the deault 404.html or 500.html
		# Respond with json. In case the environment is not production, send the exception as well.
		rescue_from StandardError do |e|
			if Rails.env.test?
				logger = Logger.new(STDOUT)
				p ""
		  	logger.error e.message
		  	logger.error e.backtrace.join("\n\t")
		  end
	  	render json: format_errors({ base: [Rails.env.production? ? 'Operation Failed' : e.message] }), status: 500
	  end

	  # Object to pass to every Active Model Serializer
	  # If removed, it defaults to current_user
	  serialization_scope :params
end
