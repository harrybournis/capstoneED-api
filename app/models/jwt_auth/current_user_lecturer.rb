class JWTAuth::CurrentUserLecturer < JWTAuth::CurrentUser

	def projects(options={})
		Project.eager_load(options[:includes]).where(lecturer_id: @id)
	end

	def units(options={})
		Unit.where(lecturer_id: @id).eager_load(options[:includes])
	end

	def departments(options={})
		Department.joins(:units).where(['units.lecturer_id = ?', @id])
	end

	def teams(options={})
		Team.joins(:project).eager_load(options[:includes]).where(['projects.lecturer_id = ?', @id])
	end

	def questions(options={})
		Question.eager_load(options[:includes]).where(lecturer_id: @id)
	end

	def iterations(options={})
		if options[:includes]
			includes = options[:includes].unshift('pa_form')
		else
			includes = 'pa_form'
		end
		Iteration.joins(:project).eager_load(includes).where(['projects.lecturer_id = ?', @id])
	end

	def pa_forms(options={})
		PAForm.joins(:iteration, :project).eager_load(options[:includes]).where(['projects.lecturer_id = ?', @id])
	end

	def peer_assessments(options={})
		PeerAssessment.joins(:project).eager_load(options[:includes]).where(['projects.lecturer_id = ?', @id])
	end


	# The associations that the current_user can include in the query
	#
	# ##
	def project_associations
   	%w(lecturer unit teams students iterations pa_forms)
	end

	def unit_associations
	  %w(lecturer projects department)
	end

	def team_associations
		%w(project students)
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
