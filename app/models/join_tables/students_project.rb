class JoinTables::StudentsProject < ApplicationRecord
	# Attributes
	# student_id 	:integer
	# project_id	:integer
	# nickname		:string

	# Associations
	belongs_to :student
	belongs_to :project

	# Validations
	validates_presence_of :project_id, :student_id
	validates_uniqueness_of :student_id, scope: :project_id, message: 'can not exist in the same Project twice'
	validates_uniqueness_of :nickname, scope: :project_id, case_sensitive: false, message: 'has already been taken for this project', allow_nil: true
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
