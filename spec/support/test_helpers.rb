module TestHelpers

	def parse_body
		JSON.parse(response.body)
	end

	def get_lecturer_with_units_projects_teams
		@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
		@lecturer.save
		@lecturer.confirm
		2.times { @lecturer.units << FactoryGirl.build(:unit, lecturer: @lecturer) }
		@lecturer.units.each { |unit| unit.projects << Array.new(2){ FactoryGirl.build(:project, lecturer: @lecturer) } }
		@lecturer.projects.each { |project| project.teams << Array.new(3){ FactoryGirl.build(:team) } }
		return @lecturer
	end

end
