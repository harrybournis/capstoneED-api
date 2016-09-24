class PAForm < ApplicationRecord
	# Attributes
	# iteration_id 	:integer
	# questions 		:jsonb { question_id => question_text }

	# Associations
	belongs_to 	:iteration, inverse_of: :pa_form
	has_many 		:peer_assessments
	has_one 		:project, through: :iteration
	has_many 		:teams, through: :project
	has_many 		:students_teams, through: :teams

	# Validations
	validates_presence_of 	:iteration, :questions
	validates_uniqueness_of :iteration, message: 'is already associated with a PAForm'
	validate 								:format_of_questions

	# Instance Methods

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


	private

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
end
