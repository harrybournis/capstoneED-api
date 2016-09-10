class JWTAuth::CurrentUserStudent < JWTAuth::CurrentUser

	def projects(options={})
		Project.joins(:students_teams).where(['students_teams.student_id = ?', @id]).eager_load(options[:includes])
	end

	def units(options={})
		Unit.joins(:projects, :teams, :students_teams).eager_load(options[:includes]).where(['students_teams.student_id = ?', @id])
	end

	def teams(options={})
		Team.joins(:students_teams).where(['students_teams.student_id = ?', @id]).eager_load(options[:includes])
	end


	# The associations that the current_user can include in the query
	#
	# ##
	def project_associations
   	['lecturer', 'unit', 'teams', 'students'] ### CAN THE STUDENT GET THE OTHER STUDENTS OF OTHER TEAMS??
	end

	def unit_associations
	  ['lecturer', 'department']
	end

	def team_associations
		['project', 'students', 'lecturer']
	end
end
