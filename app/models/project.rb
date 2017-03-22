##
# A Project belongs to a Unit and connects contains Students.
# It is created by a Lecturer
class Project < ApplicationRecord
  # Attributes
  # project_name    :string
  # team_name       :string
  # enrollment_key  :string
  # logo            :string
  # description     :string
  # color           :string
  # assignment_id   :integer
  # unit_id         :integer

  include Project::Evaluatable,
          Project::Enrollable,
          Project::Colorable

  # Associations
  belongs_to  :assignment, inverse_of: :projects
  belongs_to  :unit
  has_one     :lecturer, through: :assignment
  has_one     :extension
  has_many    :students_projects, class_name: JoinTables::StudentsProject
  has_many    :students, through: :students_projects, dependent: :delete_all
  has_many    :iterations, through: :assignment
  has_many    :project_evaluations
  has_many    :peer_assessments

  # Validations
  validates_presence_of :project_name,
                        :assignment,
                        :team_name,
                        :unit,
                        :assignment
  validates_uniqueness_of :id, :enrollment_key
  validates_uniqueness_of :project_name,
                          scope: :assignment_id,
                          case_sensitive: false
  validates_uniqueness_of :team_name,
                          scope: :assignment_id,
                          case_sensitive: false

  before_validation :generate_enrollment_key,
                    :generate_team_name,
                    :unit_from_assignment

  # Class Methods
  def self.active
    joins(:assignment, :unit).where(["units.archived_at is null and assignments.end_date >= ?",
                                     DateTime.now])
  end

  # Returns an array of StudentMembers POROs that contain all attributes of
  # the student,
  # plus their nicname for the current project
  def student_members
    students_projects.map { |sp| Decorators::StudentMember.new(sp.student, sp) }
  end

  # Returns the sum of the students' points
  def total_points
    students_projects.select(:points).sum :points
  end

  # Returs the average of all students' points
  def average_points
    students_projects.select(:points).average :points
  end

  private

  def unit_from_assignment
    self.unit = assignment.unit if assignment && assignment.unit && !persisted?
  end
end
