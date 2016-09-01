class JoinTables::StudentsTeam < ApplicationRecord

	# Associations
	belongs_to :student
	belongs_to :team

	# Validations
	validates_presence_of :team_id, :student_id
	validates_uniqueness_of :student_id, scope: :team_id, message: 'can not exist in the same Team twice'
	validate :student_id_unique_for_teams_project

	# Instance Methods
	private
		def student_id_unique_for_teams_project
			if team.project.students.include? student
				errors[:student_id] << 'has already enroled in a different team for this Project'
			end
		end
end
