class ApplicationController < JWTApplicationController

	# Handle any unexpected exceptions. Instead of rendering the deault 404.html or 500.html
	# Respond with json. In case the environment is not production, send the exception as well.
	rescue_from StandardError do |e|
  	render json: format_errors({ base: [Rails.env.production? ? 'Operation Failed' : e.message] }), status: 500
  end

  serialization_scope :params

	protected

		# Checks if the 'id' of the 'resource' provided is assotiated with
		# the current_user. If it is, a variable is created with the value
		# passed in the 'variable' parameter.
		#
		# @param [Class] 		resource 	The class of the resource
		# @param [Integer]	id 				The id of the resource'
		# @param [String]		variable	The variable name that the resource will be available under
		def set_if_owner(resource, resource_id, variable, includes = params[:includes])
			if includes
				return false unless includes_array = validate_includes_for_model(resource, includes)

				temp = resource.set_if_owner(resource_id, current_user, includes_array)
			else
				temp = resource.set_if_owner(resource_id, current_user)
			end

			if temp
				instance_variable_set "#{variable}", temp
				return true
			else
				render json: format_errors({ base: ["This #{resource} is not associated with the current user"] }), status: :forbidden
				return false
			end
		end

		# validates
		def validate_includes_for_model(resource, includes)
			includes_array = includes.split(',')

			unless resource.associations.length < includes_array.length
				valid = true
				includes_array.each { |e| valid = false unless resource.associations.include? e }
				return includes_array if valid
			end
			render json: format_errors({ base: ["Invalid 'includes' parameter. #{resource} resource accepts only: #{Project.associations.join(', ')}. Received: #{params[:includes]}."] }), status: :bad_request
			return false
		end

		# Is passed to the render method in the controllers. It provides an abstraction in the controller,
		# while initializing the correct Serializer depending on the received parameters.
		# Serializes a single object. Used in: :show, :create, :update
		#
		# @param [String] resource The resource(s) that is to be rendered in json
		def serialize_params(resource, status)
			if params[:includes]
				if params[:compact]
					render 	json: resource, include: sanitize_includes, serializer: "IncludesCompact::#{resource.class.to_s}Serializer".constantize, status: status
				else
					render  json: resource, include: sanitize_includes, serializer: "Includes::#{resource.class.to_s}Serializer".constantize,  status: status
				end
			else
				render json: resource, serializer: "#{resource.class.to_s}Serializer".constantize, status: status
			end
		end

		# Is passed to the render method in the controllers. It provides an abstraction in the controller,
		# while initializing the correct Serializer depending on the received parameters.
		# Serializes an Array. Used in: :index
		#
		# @param [String] 				resource 	The resource(s) that is to be rendered in json
		# @param [Symbol|Integer] status 		The status of the response that will be rendered
		def serialize_collection_params(resource, status)
			return [] unless resource.any?
			if params[:includes]
				if params[:compact]
					render 	json: resource, include: sanitize_includes, each_serializer: "IncludesCompact::#{resource[0].class.to_s}Serializer".constantize, status: status
				else
					render  json: resource, include: sanitize_includes, each_serializer: "Includes::#{resource[0].class.to_s}Serializer".constantize,  status: status
				end
			else
				render json: resource, each_serializer: "#{resource[0].class.to_s}Serializer".constantize, status: status
			end
		end

		# Removes the '*' symbol from the inlcudes, to protect from users abusing the ?includes parameter
		# in the requests. If not escaped, the serializer would render all of the resource's associations
		# if passed ?includes=* or ?includes=**
		def sanitize_includes
			params[:includes].tr('*','')
		end
end
