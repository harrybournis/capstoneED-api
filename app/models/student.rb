class Student < User
	# Attributes
	# first_name 	:string
	# last_name		:string
	# email				:string
	# provider		:string (email, facebook)
	# type				:string Student

	# Associations
	has_many 	:students_teams, class_name: JoinTables::StudentsTeam
	has_many 	:teams, through: :students_teams, dependent: :destroy
	has_many 	:projects, through: :teams
	has_many 	:peer_assessments_submitted_by, class_name: PeerAssessment, foreign_key: :submitted_by_id
	has_many 	:peer_assessments_submitted_for, class_name: PeerAssessment, foreign_key: :submitted_for_id

	# Validations
	validates_absence_of :position, :university
	validates_inclusion_of :type, in: ['Student']

	# Instance Methods
	def teammates
		Student.joins(:teams).where('teams.id' => teams.ids).where.not(id: id).distinct
	end
end
