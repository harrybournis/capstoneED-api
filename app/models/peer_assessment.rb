## A Peer Assessemnt form submission by a Student
class PeerAssessment < ApplicationRecord
  # Attributes
  # pa_form_id        :integer
  # submitted_by_id   :integer
  # submitted_for_id  :integer
  # date_submitted    :datetime
  # answers           :jsonb    { question_id => answer }

  # Associations
  belongs_to :pa_form
  belongs_to :submitted_by, class_name: Student, foreign_key: :submitted_by_id
  belongs_to :submitted_for, class_name: Student, foreign_key: :submitted_for_id
  belongs_to :project
  has_one :iteration, through: :pa_form
  has_one :assignment, through: :iteration
  has_one :lecturer, through: :assignment

  # Validations
  validates_presence_of :pa_form_id,
                        :submitted_for_id,
                        :submitted_by_id,
                        :answers,
                        :project_id
  validates_uniqueness_of :pa_form,
                          scope: [:submitted_for_id, :submitted_by_id],
                          message: 'has already been completed for this student'
  validate :submitted_for_is_in_the_same_team
  validate :pa_form_is_from_project_that_student_belongs_to
  validate :format_of_answers
  validate :submit_is_before_deadline
  validate :submit_is_after_start_date

  # Callbacks
  before_validation :add_project_id

  # Performs a query with the provided parameters in the hash
  # Accepted values: pa_form_di, submitted_by_id, submitted_for_id,
  # project_id, iteration_id.
  def self.api_query(hash)
    query = {}
    query[:pa_form_id] = hash['pa_form_id'] if hash['pa_form_id']
    query[:submitted_by_id] = hash['submitted_by_id'] if hash['submitted_by_id']
    query[:submitted_for_id] = hash['submitted_for_id'] if hash['submitted_for_id']
    query[:project_id] = hash['project_id'] if hash['project_id']

    if hash['iteration_id']
      query[:deliverables] = { iteration_id: hash['iteration_id'] }
      return joins(:pa_form).where(query)
    end

    query.empty? ? [] : where(query)
  end

  # Assigns the current time as date_submitted
  def submit
    self.date_submitted = DateTime.now
    save ? self : nil
  end

  def submitted?
    date_submitted.present?
  end

  private

  # Adds the project_id from the associated pa_form
  def add_project_id
    return unless !persisted? && submitted_for
    temp = submitted_for.projects.select(:id).where(assignment_id: pa_form.assignment.id)
    self.project_id = temp[0].id unless temp.empty?
  end

  # answers validation
  def format_of_answers
    return unless answers.present?

    unless answers.is_a? Array
      errors.add(:answers, 'is not an Array')
      return
    end

    answers.each do |q|
      unless q.length == 2 && q['question_id'].present? && q['answer'].present?
        errors.add(:answers, "invalid parameters. Only 'question_id' and 'answer' are accepted, and they must BOTH be present for each question.")
        break
      end
    end
  end

  # date_submitted validation
  # Validates that the submission is withing the deadline
  def submit_is_before_deadline
    return if date_submitted.nil? || date_submitted <= pa_form.deadline
    errors.add(:date_submitted, "deadline for the PAForm has passed. Deadline was #{pa_form.deadline.to_formatted_s(:long_ordinal)}")
  end

  # date_submitted validation
  # validates that the PAForm is open for submission
  def submit_is_after_start_date
    return if date_submitted.nil? || date_submitted >= pa_form.start_date
    errors.add(:date_submitted, "this PAForm is not yet available for submission. Try after #{pa_form.start_date.to_formatted_s(:long_ordinal)}")
  end

  # submitted_fo validation
  # validates that the submitted_for student belongs to the same teams
  # submitted_by
  def submitted_for_is_in_the_same_team
    return if submitted_for_id.nil? || submitted_by_id.nil? ||
              submitted_by.teammates.include?(submitted_for)
    errors.add(:submitted_for, 'is not in the same Project with the current user')
  end

  # validates that submitted_for belongs in a Team in the PAForm's Project
  def pa_form_is_from_project_that_student_belongs_to
    return if pa_form_id.nil? || submitted_by_id.nil? ||
              submitted_by.assignments.include?(pa_form.assignment)
    errors.add(:pa_form, 'is for an Assignment that the current user does not belong to')
  end
end
