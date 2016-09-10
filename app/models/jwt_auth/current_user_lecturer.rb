class JWTAuth::CurrentUserLecturer < JWTAuth::CurrentUser

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
	#
	# ##
	def project_associations
   	['lecturer', 'unit', 'teams', 'students']
	end

	def unit_associations
	  ['lecturer', 'projects', 'department']
	end

	def team_associations
		['project', 'students']
	end
end
