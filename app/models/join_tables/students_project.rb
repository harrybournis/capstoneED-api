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
	validate :student_id_unique_for_projects_assignment, on: :create
	validate :format_of_last_log


	# Instance Methods

	# Add a new log entry. Adds date_submitted field with the current time
	# If the entry is not a Hash, an empty array is added so that
	# the format_of_last_log validation fails
	def add_log(entry)
		if entry.class == Hash
			self.logs << entry.merge(date_submitted: DateTime.now.to_i)
		else
			self.logs << []
		end
	end

	private

		# student_id validation
		def student_id_unique_for_projects_assignment
			if project.assignment.students.include? student
				errors.add(:student_id, 'has already enroled in a different Project for this Assignment')
			end
		end

		# validates the format of logs before saving
		def format_of_last_log
			return unless self.logs && self.logs_changed? && !self.logs.empty? # validation will only execute if logs has been updated

			entry = logs[0]

			# Validate Formatting
			unless entry.class == Hash
				errors.add(:logs, 'entry is not a Hash')
				return
			end

			# Validate correct number of parameters and valid hash keys
			if entry.length == 5
				unless entry[:date_worked] && entry[:date_submitted] && entry[:time_worked] && entry[:stage] && entry[:text]
					errors.add(:logs, 'wrong parameter key. Keys should be date_worked, time_worked, stage, text.')
					return
				end
			elsif entry.length < 5
				errors.add(:logs, 'parameter is missing from new entry. Keys should be date_worked, time_worked, stage, text.')
				return
			else
				errors.add(:logs, 'wrong number of parameters. Keys should be date_worked, time_worked, stage, text.')
			end

			# Validate that dates are integers
			unless entry[:date_worked].class == Fixnum # WILL NOT WORK IN RUBY 2.4. USE INTEGER!!!!!!
				errors.add(:logs, "date_worked must be an integer")
				return
			end

			unless entry[:time_worked].class == Fixnum # WILL NOT WORK IN RUBY 2.4. USE INTEGER!!!!!!
				errors.add(:logs, "time_worked must be an integer")
				return
			end

			# Validate that date_worked is in the past
			unless entry[:date_worked] <= DateTime.now.to_i
				errors.add(:logs, "date_worked can't be in the future")
				return
			end

			# Validate that stage is a string
			unless entry[:stage].class == String
				errors.add(:logs, "stage must be a string")
				return
			end

			# Validate that text is a string
			unless entry[:text].class == String
				errors.add(:logs, "text must be a string")
				return
			end
		end
end
