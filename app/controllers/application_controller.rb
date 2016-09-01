class ApplicationController < JWTApplicationController

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
