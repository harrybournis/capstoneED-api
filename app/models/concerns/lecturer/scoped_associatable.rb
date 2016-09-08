module Lecturer::ScopedAssociatable

	extend ActiveSupport::Concern

	# Returns the projects of the current user
	def projects(options={})
		if options[:includes]
			return nil unless includes_array = validate_includes(project_associations, options[:includes], 'Projects')
		end
		Project.where(lecturer_id: @id).eager_load(includes_array)
	end

	private

		# The associations that the current_user can include in the query
		def project_associations
	   	['lecturer', 'unit', 'teams', 'students'] ### CAN THE STUDENT GET THE OTHER STUDENTS OF OTHER TEAMS??
		end

	  # Returns an array or resources to be included in the query if the items
	  # in the includes param are contained within the <resource>_associations array
	  # for the current_user.
	  #
	  # @param [Array] 	associations 	The <resource>_associations method that conrresponds to the current resource. Example: project_associations
	  # @param [String] includes 			The param[:includes] usually. Resources separated by comma. Example: 'teams,students,units'
	  # @param [String] resource 			A String representing the name of the resource. Only used to display errors to the user.
	  # @return [String] If valid, the 'includes' parameter in array form. Else nil.
		def validate_includes(associations, includes, resource)
			includes_array = includes.split(',')

			unless associations.length < includes_array.length
				valid = true
				includes_array.each { |e| valid = false unless associations.include? e }
				return includes_array if valid
			end
			render json: format_errors({ base: ["Invalid 'includes' parameter. #{resource} resource accepts only: #{Project.associations.join(', ')}. Received: #{params[:includes]}."] }), status: :bad_request
			return nil
		end
end
