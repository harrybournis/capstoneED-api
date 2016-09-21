class PAForm < ApplicationRecord
	# Attributes id(Integer), iteration_id(Integer), questions: { question_id => question_text }(hash)

	# Associations
	belongs_to :iteration

	# Validations
	validates_presence_of :iteration_id, :questions
	validate :format_of_questions

	# Instance Methods
	def store_questions(questions_array)
		jsonb_array = []

		index = 0
		while index < questions_array.length
			jsonb_array << { 'question_id' => index + 1, 'text' => questions_array[index] }
			index += 1
		end

		self.questions = jsonb_array

		return self
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
