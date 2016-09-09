class JWTAuth::CurrentUserLecturer < JWTAuth::CurrentUser

	def lecturer_only
	end

	# Returns the projects of the current user
	# @param [String] includes Optional. The resources to be included in the query, in the form of a single stirng, separated by commas.
	def projects(options={})
		Project.eager_load(options[:includes]).where(lecturer_id: @id)
	end

	def units(options={})
		Unit.where(lecturer_id: @id).eager_load(options[:includes])
	end

	def teams(options={})
		Team.joins(:project).eager_load(options[:includes]).where(['projects.lecturer_id = ?', @id])
	end

	# The associations that the current_user can include in the query
	def project_associations
   	['lecturer', 'unit', 'teams', 'students'] ### CAN THE STUDENT GET THE OTHER STUDENTS OF OTHER TEAMS??
	end

	def unit_associations
	  ['lecturer', 'projects', 'department']
	end

	def team_associations
		['project', 'students']
	end

	private



	  # Returns an array or resources to be included in the query if the items
	  # in the includes param are contained within the <resource>_associations array
	  # for the current_user.
	  #
	  # @param [Array] 	associations 	The <resource>_associations method that conrresponds to the current resource. Example: project_associations
	  # @param [String] includes 			The param[:includes] usually. Resources separated by comma. Example: 'teams,students,units'
	  # @param [String] resource 			A String representing the name of the resource. Only used to display errors to the user.
	  # @return [String] If valid, the 'includes' parameter in array form. Else nil.
		# def validate_includes(associations, includes, resource)
		# 	includes_array = includes.split(',')

		# 	unless associations.length < includes_array.length
		# 		valid = true
		# 		includes_array.each { |e| valid = false unless associations.include? e }
		# 		return includes_array if valid
		# 	end
		# 	render json: format_errors({ base: ["Invalid 'includes' parameter. #{resource} resource accepts only: #{Project.associations.join(', ')}. Received: #{params[:includes]}."] }), status: :bad_request
		# 	return nil
		# end
end
