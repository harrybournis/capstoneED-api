class PAForm < Deliverable
	# Attributes
	# iteration_id 	:integer
	# questions 		:jsonb { question_id => question_text }
	# start_date 		:datetime
	# deadline 			:datetime

	# Associations
	belongs_to 	:iteration
	has_many 		:peer_assessments
	has_many		:extensions, foreign_key: :deliverable_id
	has_one 		:project, through: :iteration
	has_many 		:teams, through: :project
	has_many 		:students_teams, through: :teams

	# Validations
	validates_presence_of 	:iteration, :questions, :start_offset, :end_offset
	validate 								:format_of_questions
	validate 								:start_date_is_in_the_future
	validate 								:deadline_is_after_start_date


	# Class Methods

	# Returns only the PAForms that are available for completion now
	def self.active
		joins(:iteration).where('iterations.start_date < :now and iterations.deadline > :now', now: DateTime.now)
	end


	# Instance Methods

	def start_date
		if iteration.present?
			Time.at(iteration.deadline.to_i + start_offset.to_i).to_datetime
		else
			nil
		end
	end

	def deadline
		if iteration.present?
			Time.at(iteration.deadline.to_i + end_offset.to_i).to_datetime
		else
			nil
		end
	end

	def start_date=(value)
		#self.start_offset = value.to_i
		nil
	end

	def deadline=(value)
		nil
	end

  # Override questions setter to receive an array and format and save it in the desired format
  #
  # @param 	[Array] 	questions_param The questions of the PAform as an Array in the order they are supposed to appear
	def questions=(questions_param)
		unless questions_param && questions_param.is_a?(Array) && questions_param.any?
			super(nil)
			return
		end

		questions_array = questions_param
		jsonb_array = []

		index = 0
		while index < questions_array.length
			elem = questions_array[index]

			unless elem.is_a? String
				super(nil)
				return
			end

			jsonb_array << { 'question_id' => index + 1, 'text' => elem }
			index += 1
		end

		super(jsonb_array)
	end

	# return the deadline plus the extension time if there is one for a specific team
	# if there is no extension returns just the deadline
	def deadline_with_extension_for_team(team)
		extension = Extension.where(team_id: team.id, deliverable_id: id)[0]
		if extension.present?
			Time.at(deadline.to_i + extension.extra_time).to_datetime
		else
			deadline
		end
	end

	private

		# Validation of the questions format
		#
		def format_of_questions
			return unless questions.present?

			unless questions.is_a? Array
				errors.add(:questions, "is not an Array")
				return
			end

			questions.each do |q|
				unless q.length == 2 && q['question_id'].present? && q['text'].present?
					errors.add(:questions, "missing required parameters. Only 'question_id' and 'text' are accepted, and they must BOTH be present for each question.")
					return
				end
			end
		end

		# start_date validation
		def start_date_is_in_the_future
			unless start_date.present? && start_date >= DateTime.now - 1.minute
				errors.add(:start_date, "can't be in the past")
			end
		end

		# deadline validation
		def deadline_is_after_start_date
			unless deadline.present? && start_date.present? && deadline > start_date
				errors.add(:deadline, "can't be before the start_date")
			end
		end
end
