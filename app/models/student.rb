class Student < User

	# Associations
	has_many :students_teams, class_name: JoinTables::StudentsTeam
	has_many :teams, through: :students_teams

	# Silently don't allow university or position to be assigned a value
	def university=(value) 	nil 	; end

	def position=(value) 		nil 	; end
end
