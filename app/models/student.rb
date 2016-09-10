class Student < User

	# Associations
	has_many :students_teams, class_name: JoinTables::StudentsTeam
	has_many :teams, through: :students_teams, dependent: :destroy
	has_many :projects, through: :teams

	# Validations
	validates_absence_of :position, :university
end
