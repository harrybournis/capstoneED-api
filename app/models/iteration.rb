# An Assignment can have multiple Iterations, and each
# Project and Student are assessed based on it.
# All the Projects in an Assignment share the same
# Iterations,
#
# An Iteration is closely related to Peer Assessments and
# Project Evaluations, and Students are expected to submit
# their Peer Assessments at the end of each Iteration.
# In the case of Project Evaluations,
# both the Student and the Lecturer are expected to
# submit them twice within each Iteration. An Iteration also
# determines the start_date and dealine of a PaForm.
#
# Last but not least, students are marked based on the Peer
# Assessment of each Iteration, which means that the
# performance of the Student in the overall Project is directly
# related to how they performed in each Iteration.
#
# @author [harrybournis]
#
# @!attribute name
#   @return [String] The name of the Iteration. e.g. Analysis, Deisign etc.
#
# @!attribute start_date
#   @return [DateTime] The date that the Iteration starts, and is
#     considered active.
#
# @!attribute deadline
#   @return [DateTime] The date that the Iteration ends
#
# @!attribute is_marked
#   @return [Boolean] Indicates if the iteration has already been marked.
#
# @!attribute assignment_id
#   @return [Integer] The id of the Assignment that the Iteration
#     belongs to.
#
class Iteration < ApplicationRecord
  belongs_to :assignment, inverse_of: :iterations
  has_one :pa_form,
          inverse_of: :iteration,
          dependent: :destroy
  has_many :projects, through: :assignment
  has_many :students_projects, through: :projects
  has_many :extensions, through: :pa_form
  has_many :project_evaluations
  has_many :peer_assessments, through: :pa_form
  has_one :game_setting, through: :assignment

  accepts_nested_attributes_for :pa_form

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

  # Returns true if current time is between the steart_date and
  # the deadline of the iteration.
  #
  # @return [Boolean]
  #
  def active?
    now = DateTime.now
    start_date <= now && now <= deadline
  end

  # Returns true if the current time is after the deadline.
  #
  # @return [Boolean] True if after deadline.
  #
  def finished?
    deadline <= DateTime.now
  end

  # Wrapper for is_marked attribute.
  #
  # @return [Boolean] The value of the is_marked attribute.
  #
  def marked?
    is_marked
  end

  # Wrapper for is_scored attribute.
  #
  # @return [Boolean] The value of the is_scored attribute.
  #
  def scored?
    is_scored
  end
  # Returns the iteration health (currently static CHANGE)
  def iteration_health
    54
  end

  # Returns the start_date and the deadline as a range.
  #
  # @return [Range<DateTime>] The range of the itetrations
  #   start_date and deadline.
  #
  def duration
    start_date..deadline
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
