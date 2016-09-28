module AssociationIncludable

	# Transforms the string from params[:includes] into an array, by splitting elements on the , char
	# Returns nil if inludes does not exist in the params
	#
	# @return [Array]
	def includes_array
		return nil unless params[:includes]
		@includes_array ||= params[:includes].split(',')
	end

	# Removes the '*' symbol from the inlcudes, to protect from users abusing the ?includes parameter
	# in the requests. If not escaped, the serializer would render all of the resource's associations
	# if passed ?includes=* or ?includes=**
	def sanitize_includes
		params[:includes].tr('*','')
	end

	# Deletes params[:includes]. Mainly used for the update and delete actions
	def delete_includes_from_params
		params.delete(:includes)
	end


  # Returns true if the 'includes_array' contains valid associations that match the allowed
  # associations defined in the current_user object, depending on the user type.
  #
  # @param 	[Array] 	associations 		The <resource>_associations method that conrresponds to the current resource. e.g. project_associations
  # @param 	[Array] 	includes_array 	An array of strings. The includes param can be transformed using the includes_arry method.
  # @param 	[String] 	resource 				A String representing the name of the resource. Only used to display errors to the user.
  # @return [Boolean]
	def validate_includes(associations, includes_array, resource)
		associations = current_user.method("#{controller_resource.name.underscore}_associations").call
		resource = controller_resource.name

		if associations.length >= includes_array.length
			valid = true
			includes_array.each { |e| valid = false unless associations.include? e }
			return true if valid
		end
		render json: format_errors({ base: ["Invalid 'includes' parameter. #{resource} resource for #{current_user.type} user accepts only: #{associations.join(', ')}. Received: #{params[:includes]}."] }), status: :bad_request
		return false
	end


	# Used instead of the render method in the controllers, in the index and show actions.
	# It provides an abstraction in the controller, while initializing the correct Serializer
	# depending on the received parameters. Serializes a single object.
	#
	# @param [Object] resource 	The resource to be rendered in json
	# @param [Symbol]	status		The status of the response
	def serialize_object(resource, status)
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


	# Used instead of the render method in the controllers, in the index and show actions.
	# It provides an abstraction in the controller, while initializing the correct Serializer
	# depending on the received parameters. Serializes an Array.
	#
	# @param [Array] 	resource 	The resources to be rendered in json
	# @param [Symbol] status 		The status of the response that will be rendered
	def serialize_collection(resources, status)
		return [] unless resources.length > 0
		if params[:includes]
			if params[:compact]
				render 	json: resources, include: sanitize_includes, each_serializer: "IncludesCompact::#{resources[0].class.to_s}Serializer".constantize, status: status
			else
				render  json: resources, include: sanitize_includes, each_serializer: "Includes::#{resources[0].class.to_s}Serializer".constantize,  status: status
			end
		else
			render json: resources, each_serializer: "#{resources[0].class.to_s}Serializer".constantize, status: status
		end
	end
end
