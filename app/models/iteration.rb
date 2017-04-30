## An Assignment has many Iterations
class Iteration < ApplicationRecord
  # Attributes
  # name          :string
  # start_date    :datetime
  # deadline      :datetime
  # assignment_id :integer

  # Associations
  belongs_to :assignment, inverse_of: :iterations
  has_one :pa_form,
          inverse_of: :iteration,
          dependent: :destroy
  has_many :projects, through: :assignment
  has_many :students_projects, through: :projects
  has_many :extensions, through: :pa_form
  has_many :project_evaluations
  has_many :peer_assessments, through: :pa_form

  accepts_nested_attributes_for :pa_form

  # Validations
  validates_presence_of :name, :start_date, :deadline, :assignment
  validate :takes_place_within_the_assignment_duration
  validate :deadline_is_after_start_date


  # Returns the Iterations that are currently taking place.
  # Iteration start_date must be smaller than the current time,
  # and the deadline should be bigger than the current time.
  # Can be chained with further active record question.
  #
  # @return [Iteation[]] An active record collection with the Iterations.
  #
  def self.active
    now = DateTime.now
    where(["iterations.start_date <= :now and iterations.deadline >= :now", now: now])
  end

  # return whether the iteration is currently happening
  def active?
    now = DateTime.now
    start_date <= now && now <= deadline
  end

  # Returns the start_date and the deadline as a range.
  #
  # @return [Range<DateTime>] The range of the itetrations
  #   start_date and deadline.
  #
  def duration
    start_date..deadline
  end
  # Returns the iteration health (currently static CHANGE)
  def iteration_health
    54
  end

  private

  # Validates that the iteration start_date is after the start_date of the
  # Assignment, and that the end_date is before the end_date of the assignment.
  #
  def takes_place_within_the_assignment_duration
    return unless start_date.present? && deadline.present? && assignment.present?

    unless start_date.to_i >= assignment.start_date.to_i - 1.minute
      errors.add(:start_date, "can't be before the start of the Assignment")
    end

    unless deadline.to_i <= assignment.end_date.to_i + 1.minute
      errors.add(:deadline, "can't be after the end of the Assignment")
    end
  end

  # start_date validation
  def start_date_is_in_the_future
    return if start_date.present? && start_date >= DateTime.now - 1.minute
    errors.add(:start_date, "can't be in the past")
  end

  # deadline validation
  def deadline_is_after_start_date
    return if deadline.present? && start_date.present? && deadline > start_date
    errors.add(:deadline, "can't be before the start_date")
  end
end
