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
	has_one :assignment, through: :iteration
	has_one :lecturer, through: :assignment

	# Validations
	validates_presence_of :pa_form_id, :submitted_for_id, :submitted_by_id, :answers
	validates_uniqueness_of :pa_form, scope: [:submitted_for_id, :submitted_by_id], message: 'has already been completed for this student'
	validate :submitted_for_is_in_the_same_team
	validate :pa_form_is_from_project_that_student_belongs_to
	validate :format_of_answers
	validate :submit_is_before_deadline
	validate :submit_is_after_start_date


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
		# Validates that the submission is withing the deadline
		def submit_is_before_deadline
			if date_submitted.present?
				unless date_submitted <= pa_form.deadline
					errors.add(:date_submitted, "deadline for the PAForm has passed. Deadline was #{pa_form.deadline.to_formatted_s(:long_ordinal)}")
				end
			end
		end

		# date_submitted validation
		# validates that the PAForm is open for submission
		def submit_is_after_start_date
			if date_submitted.present?
				unless date_submitted >= pa_form.start_date
					errors.add(:date_submitted, "this PAForm is not yet available for submission. Try after #{pa_form.start_date.to_formatted_s(:long_ordinal)}")
				end
			end
		end

		# submitted_fo validation
		# validates that the submitted_for student belongs to the same teams
		# submitted_by
		def submitted_for_is_in_the_same_team
			if submitted_for_id.present? && submitted_by_id.present?
				unless submitted_by.teammates.include? submitted_for
					errors.add(:submitted_for, 'is not in the same Project with the current user')
				end
			end
		end

		# validates that submitted_for belongs in a Team in the PAForm's Project
		def pa_form_is_from_project_that_student_belongs_to
			if pa_form_id.present? && submitted_by_id.present?
				unless submitted_by.assignments.include? pa_form.assignment
					errors.add(:pa_form, 'is for an Assignment that the current user does not belong to')
				end
			end
		end
end
