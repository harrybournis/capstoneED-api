class ApplicationController < JWTApplicationController

	# Handle any unexpected exceptions. Instead of rendering the deault 404.html or 500.html
	# Respond with json. In case the environment is not production, send the exception as well.
	rescue_from StandardError do |e|
  	render json: format_errors({ base: [Rails.env.production? ? 'Operation Failed' : e.message] }), status: 500
  end

  serialization_scope :params

	protected

		###
		# Checks if the 'id' of the 'resource' provided is assotiated with
		# the current_user. If it is, a variable is created with the value
		# passed in the 'variable' parameter.
		#
		# param resource, Class, 		'The class of the resource'
		# param id 			, Integer,	'The id of the resource'
		# param variable, String,		'The variable name that the resource will be available under'
		def set_if_owner(resource, id, variable)
			temp = resource.find_by(id: id)

    	unless current_user.load.method(resource.table_name).call.include? temp
    		render json: format_errors({ base: ["This #{resource} is not associated with the current user"] }), status: :forbidden
    		return false
    	end

    	instance_variable_set "#{variable}", temp
    	true
		end

		###
		# Is passed to the render method in the controllers. It provides an abstraction in the controller,
		# while initializing the correct Serializer depending on the received parameters.
		#
		# param, String, resource, The resource(s) that is to be rendered in json
		def serialize_with_options(resource)
			if params[:includes]
				{ json: resource, include: parse_includes, serializer: "#{resource.class}::#{resource.class}IncludesSerializer".constantize }
			else
				{ json: resource, serializer: "#{resource.class}::#{resource.class}Serializer".constantize }
			end
		end

		###
		# Removes the '*' symbol from the inlcudes, to protect from users abusing the ?includes parameter
		# in the requests. If not escaped, the serializer would render all of the resource's associations
		# if passed ?includes=* or ?includes=**
		def parse_includes
			params[:includes].tr('*','')
		end
end
