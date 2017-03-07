## An Assignment has many Iterations
class Iteration < ApplicationRecord
  # Attributes
  # name          :string
  # start_date    :datetime
  # deadline      :datetime
  # assignment_id :integer

  # Associations
  belongs_to :assignment
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
  validates_presence_of :name, :start_date, :deadline, :assignment_id
  validate :start_date_is_in_the_future
  validate :deadline_is_after_start_date

  # return whether the iteration is currently happening
  def active?
    now = DateTime.now
    start_date <= now && now <= deadline
  end

  # Returns the iteration health (currently static CHANGE)
  def iteration_health
    54
  end

  private

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
