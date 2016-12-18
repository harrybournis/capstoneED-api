class JoinTables::StudentsProject < ApplicationRecord
	# Attributes
	# student_id 	:integer
	# project_id	:integer

	# Associations
	belongs_to :student
	belongs_to :project

	# Validations
	validates_presence_of :project_id, :student_id
	validates_uniqueness_of :student_id, scope: :project_id, message: 'can not exist in the same Project twice'
	validate :student_id_unique_for_projects_assignment


	# Instance Methods

	private

		# student_id validation
		def student_id_unique_for_projects_assignment
			if project.assignment.students.include? student
				errors[:student_id] << 'has already enroled in a different Project for this Assignment'
			end
		end
end
