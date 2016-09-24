class PeerAssessment < ApplicationRecord
	# Attributes
	# pa_form_id				:integer
	# submitted_by_id		:integer
	# submitted_for_id	:integer
	# date_submitted		:datetime
	# answers						:jsonb 		{ question_id => answer }

	# Associations
	belongs_to :pa_form, class_name: PAForm
	belongs_to :submitted_by, class_name: Student, foreign_key: :submitted_by_id
	belongs_to :submitted_for, class_name: Student, foreign_key: :submitted_for_id

	# Validations
	validates_presence_of :pa_form_id, :submitted_for_id, :submitted_by_id, :date_submitted, :answers
	validate :format_of_answers

	# Class Methods

	# Instance Methods
	private

		def format_of_answers
			return unless answers.present?

			unless answers.is_a? Array
				errors.add(:answers, "is not an Array")
				return
			end

			answers.each do |q|
				unless q.length == 2 && q['question_id'].present? && q['answer'].present?
					errors.add(:answers, "invalid parameters. Only 'question_id' and 'answer' are accepted, and they must BOTH be present for each question.")
					return
				end
			end
		end
end
