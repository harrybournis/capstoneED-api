class JoinTables::StudentsProject < ApplicationRecord
	# Attributes
	# student_id 	:integer
	# project_id	:integer
	# nickname		:string
	# logs 				:jsonb 		:date_worked, :date_submitted, :time_worked, :stage, :text

	# Associations
	belongs_to :student
	belongs_to :project

	# Validations
	validates_presence_of :project_id, :student_id, :nickname
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
			self.logs << entry.merge("date_submitted" => DateTime.now.to_i.to_s)
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

			entry = logs.last

			# Validate Formatting
			unless entry.class == Hash
				errors.add(:log_entry, 'is not a Hash')
				return
			end

			# Validate correct number of parameters and valid hash keys
			if entry.length == 5
				unless entry["date_worked"] && entry["date_submitted"] && entry["time_worked"] && entry["stage"] && entry["text"]
					errors.add(:log_entry, 'wrong parameter key. Keys should be date_worked, time_worked, stage, text.')
					return
				end
			elsif entry.length < 5
				errors.add(:log_entry, 'parameter is missing from new entry. Keys should be date_worked, time_worked, stage, text.')
				return
			else
				errors.add(:log_entry, 'wrong number of parameters. Keys should be date_worked, time_worked, stage, text.')
			end

			# Validate that dates are integers
			begin
				date_worked = Integer(entry["date_worked"])
				Integer(entry["time_worked"])

				# validate that date_worked is not in the future
				unless date_worked <= DateTime.now.to_i
					errors.add(:log_entry, "date_worked can't be in the future")
					return
				end

			rescue
				errors.add(:log_entry, "date_worked and time_worked must be integers")
			end

			# Validate that stage is a string
			unless entry["stage"].class == String
				errors.add(:log_entry, "stage must be a string")
				return
			end

			# Validate that text is a string
			unless entry["text"].class == String
				errors.add(:log_entry, "text must be a string")
				return
			end
		end
end
