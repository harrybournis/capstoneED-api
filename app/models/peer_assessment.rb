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
	has_one :iteration, through: :pa_form
	has_one :project, through: :iteration
	has_one :lecturer, through: :project

	# Validations
	validates_presence_of :pa_form_id, :submitted_for_id, :submitted_by_id, :answers
	validate :format_of_answers
	validate :submit_is_before_deadline


	# Instance Methods

	# Assigns the current time as date_submitted
	def submit
		self.date_submitted = DateTime.now
		if save
			return self
		else
			return nil
		end
	end

	def submitted?
		return date_submitted.present?
	end

	private

		# answers validation
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

		# date_submitted validation
		def submit_is_before_deadline
			if date_submitted.present?
				unless date_submitted <= pa_form.deadline
					errors.add(:date_submitted, 'deadline for the PAForm has passed')
				end
			end
		end
end
