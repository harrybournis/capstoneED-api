class ApplicationController < JWTApplicationController

	# Handle any unexpected exceptions. Instead of rendering the deault 404.html or 500.html
	# Respond with json. In case the environment is not production, send the exception as well.
	rescue_from StandardError do |e|
  	render json: format_errors({ base: [Rails.env.production? ? 'Operation Failed' : e.message] }), status: 500
  end

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
end
