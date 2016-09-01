class ApplicationController < JWTApplicationController

	protected
		def set_if_owner(resource, id)
			temp = resource.find_by(id: id)
    	resource_str = resource.to_s

    	unless current_user.load.method(resource.table_name).call.include? temp
    		render json: format_errors({ base: ["This #{resource_str} can not be found in the current user's #{resource_str.pluralize}"] }), status: :forbidden
    	end

    	resource_str[0] = resource_str[0].downcase
    	instance_variable_set "@#{resource_str}", temp
    	true
		end
end
