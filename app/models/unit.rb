## A Lecturer creates Units
class Unit < ApplicationRecord
  # Attributes
  # name            :string
  # code            :string
  # semester        :string
  # year            :integer
  # archived_at     :date
  # department_id   :integer
  # lecturer_id     :integer

  # Associations
  belongs_to :lecturer
  belongs_to :department
  has_many :assignments
  has_many :projects
  has_many :students_projects, through: :projects
  has_many :students, through: :students_projects

  accepts_nested_attributes_for :department

  # Validations
  validates_presence_of :name, :code, :semester, :year, :lecturer_id
  validates_presence_of :department,
                        message: I18n.t('errors.models.unit.department_presence')
  validates_numericality_of :year
  validates_uniqueness_of :id

  # Returns the Units that have not been archived
  def self.active
    where(archived_at: nil)
  end

  # Returns only the archived Units
  def self.archived
    where.not(archived_at: nil)
  end

  # Sets archived_at date to the current date
  def archive
    if archived?
      errors.add(:unit, I18n.t('errors.models.unit.archive'))
      false
    else
      self.archived_at = Date.today
      save
    end
  end

  def archived?
    archived_at.present?
  end
end
