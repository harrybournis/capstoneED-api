class JWTAuth::CurrentUserStudent < JWTAuth::CurrentUser

	def projects(options={})
		Project.joins(:students_teams).where(['students_teams.student_id = ?', @id]).eager_load(options[:includes]).distinct
	end

	def units(options={})
		Unit.joins(:projects, :teams, :students_teams).where(['students_teams.student_id = ?', @id]).eager_load(options[:includes]).distinct
	end

	def teams(options={})
		Team.joins(:students_teams).where(['students_teams.student_id = ?', @id]).eager_load(options[:includes])
	end

	def iterations(options={})
		Iteration.joins(:project, :teams, :students_teams).where(['students_teams.student_id = ?', @id]).eager_load(options[:includes]).distinct
	end


	# The associations that the current_user can include in the query
	#
	# ##
	def project_associations
		%w(lecturer unit teams iterations students)
	end

	def unit_associations
	  %w(lecturer department)
	end

	def team_associations
		%w(project students lecturer)
	end

	def iteration_associations
		[]
	end
end
