class JWTAuth::CurrentUserStudent < JWTAuth::CurrentUser

	def projects(options={})
		Project.joins(:students_teams).where(['students_teams.student_id = ?', @id]).eager_load(options[:includes]).distinct
	end

	def units(options={})
		Unit.joins(:students_teams).where(['students_teams.student_id = ?', @id]).eager_load(options[:includes]).distinct
	end

	def teams(options={})
		Team.joins(:students_teams).where(['students_teams.student_id = ?', @id]).eager_load(options[:includes])
	end

	def iterations(options={})
		if options[:includes]
			includes = options[:includes].unshift('pa_form')
		else
			includes = 'pa_form'
		end
		Iteration.joins(:students_teams).where(['students_teams.student_id = ?', @id]).eager_load(includes).distinct
	end

	def pa_forms(options={})
		PAForm.joins(:students_teams).where(['students_teams.student_id = ?', @id]).eager_load(options[:includes]).distinct
	end

	def peer_assessments(options={})
		PeerAssessment.where(['submitted_for_id = ? or submitted_by_id = ?', @id, @id]).eager_load(options[:includes])
	end

	def peer_assessments_for(options={})
		PeerAssessment.where(['submitted_for_id = ?', @id]).eager_load(options[:includes])
	end

	def peer_assessments_by(options={})
		PeerAssessment.where(['submitted_by_id = ?', @id]).eager_load(options[:includes])
	end

	# The associations that the current_user can include in the query
	#
	# ##
	def project_associations
		%w(lecturer unit teams iterations students pa_forms)
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

	def pa_form_associations
		%w(iteration)
	end

	def peer_assessment_associations
		%w(pa_form submitted_by submitted_for)
	end
end
