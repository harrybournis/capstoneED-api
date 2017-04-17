# A Unit contains multiple Assignments, each of which contains Projects.
# To use the system, a Lecturer has to first create a Unit.
# For identification, a Unit contains a name, a year and a semester,
# as well as a 'code', which is the identifier of the Unit within
# the university. Α Unit can be archived by the lecturer, after it has
# been completed and there is not reason for them to see it on their dashboard.
# Archiving a Unit will set the archived_at date, which will exclude the unit
# from being included in the GET /units endpoint. Instead, the Unit can
# be found in the GET /units/archived endpoint.
#
# A Unit has an association with a Department, which is also created by
# the Lecturer. By default, the Department will be included with the
# Unit when it is serialized.
#
# @!attribute name
#   @return [String] The name of the Unit
#
# @!attribute code
#   @return [String] A code that identifies the Unit within the University.
#     No presumptions are made about the format of this code, and no limitations
#     are placed on the input string.
#
# @!attribute year
#   @return [Integer] The year that the Unit takes place.
#
# @!attribute semeseter
#   @return [String] The academic semester that the Unit takes place. Usually
#     this is 'autumn' or 'spring', although no limitations are placed on the input.
#
# @!attribute archived_at
#   @return [Date] The date that the Unit was archived. If it is null, then the
#     Unit is supposed to be active. Currently, there is no way to 'unarchive' a
#     Unit.
#
# @!attribute [r] lecturer_id
#   @return [Integer] The id of the Lecturer that created the Unit. This attribute
#     can not be changed by the user.
#
# @!attribute department_id
#   @return [Integer] The id of the Department that the Unit belongs to.
#
class Unit < ApplicationRecord
  belongs_to :lecturer
  belongs_to :department
  has_many :assignments
  has_many :projects
  has_many :students_projects, through: :projects
  has_many :students, through: :students_projects

  accepts_nested_attributes_for :department

  validates_presence_of :name, :code, :semester, :year, :lecturer_id
  validates_presence_of :department,
                        message: I18n.t('errors.models.unit.department_presence')
  validates_numericality_of :year
  validates_uniqueness_of :id

  # Returns the Units that have not been archived
  #
  # @return [Array<Unit>]
  #
  def self.active
    where(archived_at: nil)
  end

  # Returns only the archived Units
  #
  # @return [Array<Unit>]
  #
  def self.archived
    where.not(archived_at: nil)
  end

  # Sets archived_at date to the current date. The Unit is
  # considered archived after the archived_at date has been
  # set.
  #
  # @return [Array<Unit>]
  #
  def archive
    if archived?
      errors.add(:unit, I18n.t('errors.models.unit.archive'))
      false
    else
      self.archived_at = Date.today
      save
    end
  end

  # Returns whether the Unit has been archived. Checks if the
  # archived_at attribute has been set or it is null.
  #
  # @return [Boolean] Returns true if the Unit has been archived.
  #
  def archived?
    archived_at.present?
  end
end
