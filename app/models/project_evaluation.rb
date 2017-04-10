## A Project can be Evaluated by both a Lecturer and a Student
class ProjectEvaluation < ApplicationRecord
  # Attributes
  #
  # user_id           :integer
  # project_id        :integer
  # iteration_id      :integer
  # feeling_id        :integer
  # percent_complete  :integer
  # date_submitted    :datetime

  # Associations
  belongs_to :project
  belongs_to :iteration
  belongs_to :user
  belongs_to :feeling
  has_many :project_evaluation_points

  # Validations
  validates_presence_of :project_id,
                        :iteration_id,
                        :feeling_id,
                        :user_id,
                        :percent_complete,
                        :date_submitted
  validates_inclusion_of :percent_complete,
                         in: 0..100,
                         message: 'must be between 0 and 100'
  validate :iteration_belongs_to_the_project
  validate :iteration_is_active
  validate :user_is_associated_with_project
  validate :iteration_limit_of_evaluations_has_not_been_reached_for_user

  # Callbacks
  before_validation :assign_date_submitted_to_current_time

  # Constants
  NO_OF_EVALUATIONS_PER_ITERATION = 2

  private

  # assigns the date submitted to the current time unless it is not a new record
  def assign_date_submitted_to_current_time
    self.date_submitted = DateTime.now unless persisted?
  end

  # Validates that the iteration_id and project_id are associated through
  # the same assignment
  def iteration_belongs_to_the_project
    return unless iteration_id && project_id

    return if project.iterations.exists?(id: iteration_id)
    errors.add(:iteration_id, 'does not belong to project_id')
  end

  # validates that the iteration is currently active
  def iteration_is_active
    if iteration_id && !iteration.active?
      errors.add(:iteration_id, "is not a currently active Iteration. Submission must be no later that the iteration's deadline.")
    end
  end

  # checks whether the user is associated with the project,
  # either as a Lecturer or Student
  def user_is_associated_with_project
    return if user_id.nil? || project_id.nil? ||
              user.projects.exists?(id: project.id)
    errors.add(:user_id, 'is not associated with this Project')
  end

  # checks whether the particular User has submitted more that the allowed
  # number of ProjectEvaluation for the current Iteration
  def iteration_limit_of_evaluations_has_not_been_reached_for_user
    return if iteration_id.nil? || user_id.nil? || project_id.nil? ||
              iteration.project_evaluations.where(user_id: user_id, project_id: project_id).count < NO_OF_EVALUATIONS_PER_ITERATION
    errors.add(:iteration_id, "the limit of ProjectEvaluations for this iteration has been reached")
  end
end
