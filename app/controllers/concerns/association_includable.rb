## Methods that deal with the 'includes functionality of the API'
#
module AssociationIncludable
  # Transforms the string from params[:includes] into an array,
  # by splitting elements on the , char
  # Returns nil if inludes does not exist in the params
  #
  # @return [Array] The includes params as an array.
  #
  def includes_array
    return nil unless params[:includes]
    @includes_array ||= params[:includes].split(',')
  end

  # Removes the '*' symbol from the inlcudes, to protect from users
  # abusing the ?includes parameter in the requests. If not escaped,
  #  the serializer would render all of the resource's associations
  # if passed ?includes=* or ?includes=**
  #
  def sanitize_includes
    params[:includes].tr('*', '')
  end

  # Deletes params[:includes]. Mainly used for the update and delete actions
  #
  def delete_includes_from_params
    params.delete(:includes)
  end

  # Returns true if the 'includes_array' contains valid associations
  # that match the allowed associations defined in the current_user
  # object, depending on the user type. Renders errors with status
  # 400 Bad Request.
  #
  # @return [Boolean] True if valid includes params, False if invalid.
  #
  def validate_includes
    associations = current_user.method("#{controller_resource.name.underscore}_associations").call
    resource = controller_resource.name

    if associations.length >= includes_array.length
      valid = true
      includes_array.each { |e| valid = false unless associations.include? e }
      return true if valid
    end
    render json: format_errors(base: [
                                 I18n.t('errors.modules.association_includable.validate_includes',
                                        resource: resource.to_s,
                                        user_type: current_user.type.to_s,
                                        associations: associations.join(', ').to_s,
                                        received: params[:includes].to_s)
                               ]),
           status: :bad_request
    false
  end

  # Used instead of the render method in the controllers, in the index
  # and show actions. It provides an abstraction in the controller,
  # while initializing the correct Serializer depending on the received
  # parameters. Alternatively, a serializer can be specified through
  # the optional third parameter. Serializes a single object.
  #
  # @param [Object] resource  The resource to be rendered in json
  # @param [Symbol] status    The status of the response
  #
  def serialize_object(resource, status, serializer = nil)
    klass = serializer ? serializer : "#{resource.class}Serializer"

    if params[:includes]
      if params[:compact]
        render  json: resource,
                include: sanitize_includes,
                serializer: "IncludesCompact::#{klass}".constantize,
                status: status
      else
        render  json: resource,
                include: sanitize_includes,
                serializer: "Includes::#{klass}".constantize,
                status: status
      end
    else
      render json: resource, serializer: "#{klass}".constantize, status: status
    end
  end

  # Used instead of the render method in the controllers, in the index
  # and show actions. It provides an abstraction in the controller,
  # while initializing the correct Serializer depending on the received
  # parameters. Alternatively, a serializer can be specified through
  # the optional third parameter. Serializes an Array.
  #
  # @param [Array]  resource  The resources to be rendered in json
  # @param [Symbol] status    The status of the response that will be rendered
  # @param [Class] serializer Optional. A serializer can be specified
  #
  def serialize_collection(resources, status, serializer = nil)
    return [] unless resources.length > 0
    klass = serializer ? serializer.to_s : "#{resources[0].class.to_s}Serializer"

    if params[:includes]
      if params[:compact]
        render  json: resources,
                include: sanitize_includes,
                each_serializer: "IncludesCompact::#{klass}".constantize,
                status: status
      else
        render  json: resources,
                include: sanitize_includes,
                each_serializer: "Includes::#{klass}".constantize,
                status: status
      end
    else
      render json: resources, each_serializer: klass.to_s.constantize, status: status
    end
  end
end
