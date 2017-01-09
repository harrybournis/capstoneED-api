class Student < User
	# Attributes
	# first_name 	:string
	# last_name		:string
	# email				:string
	# provider		:string (email, facebook)
	# type				:string Student

	# Associations
	has_many 	:students_projects, class_name: JoinTables::StudentsProject
	has_many 	:projects, through: :students_projects, dependent: :destroy
	has_many 	:assignments, through: :projects
	has_many 	:peer_assessments_submitted_by, class_name: PeerAssessment, foreign_key: :submitted_by_id
	has_many 	:peer_assessments_submitted_for, class_name: PeerAssessment, foreign_key: :submitted_for_id

	# Validations
	validates_absence_of :position, :university
	validates_inclusion_of :type, in: ['Student']


	# Instance Methods

	# returns all the Students that share a Team with self
	def teammates
		Student.joins(:projects).where('projects.id' => projects.ids).where.not(id: id).distinct
	end

	# returns the Student's nickname for the provided project
	# Returns the full_name if no nickname is found
	def nickname_for_project_id(project_id)
		JoinTables::StudentsProject.select(:nickname).where(project_id: project_id, student_id: self.id)[0].nickname
	rescue
		nil
	end
end
