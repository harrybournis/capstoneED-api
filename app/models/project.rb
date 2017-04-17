# The Project is one of the main entities of the System.
# It is synonymous to 'Team'. A number of Students participate
# in Project, which belongs to an Assignment. A Project has
# multiple iterations, through the Assignment, which means that
# Projects of the same Assignment share Iterations.
#
# A Project contains an enrollment_key, which is set by the Lecturer
# upon creation. In order for a Student to join a Project, they have
# to supply the Project's 'id' and the 'enrollment_key'.
#
# A Project has an 'official' project_name, and also a team_name.
# Finally, a Project has a logo, and a randomly generated color,
# both of which aim personalize the experience for the Students.
#
# @author [harrybournis]
#
# @!attribute project_name
#   @return [String] The 'official' name of the Project.
#
# @!attribute team_name
#   @return [String] The name of the Team working on the
#     Project.
#
# @!attribute description
#   @return [String] A short description of the Project. Set by the
#     Lecturer.
#
# @!attribute enrollment_key
#   @return [String] Set by the Lecturer, it is used by a Student
#     in combination with the Project's id to enroll in a new Project.
#
# @!attribute [r] assignment_id
#   @return [Integer] The id of the Assignment that the Project belongs to.
#
# @!attribute [r] unit_id
#   @return [Integer] The id of the Unit that the Unit belongs to.
#
# @!attribute [r] color
#   @return [String] A randomly generated HEX color of fixed saturation and lightness.
#
# @!attribute logo
#   @return [String] The URL of the logo of the Project.
#
class Project < ApplicationRecord
  include Project::Evaluatable,
          Project::Enrollable,
          Project::Colorable,
          Project::Awardable

  belongs_to  :assignment, inverse_of: :projects
  belongs_to  :unit
  has_one     :lecturer, through: :assignment
  has_one     :extension
  has_many    :students_projects, class_name: JoinTables::StudentsProject
  has_many    :students, through: :students_projects, dependent: :delete_all
  has_many    :iterations, through: :assignment
  has_many    :project_evaluations
  has_many    :peer_assessments

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


  # Queries all the projects that are currently 'active', meaning that
  # their Assignment's end_date is in the future, and their Unit has not
  # been archived.
  #
  # @return [Project[]] An array of currently active Projects.
  #
  def self.active
    joins(:assignment, :unit).where(["units.archived_at is null and assignments.end_date >= ?",
                                     DateTime.now])
  end

  # Returns an array of StudentMembers POROs that contain all attributes of
  # the student, plus their nicname for the current Project.
  #
  # @return [StudentMember[]] A StudentMember PORO with the nickname for
  #   the current project.
  #
  def student_members
    students_projects.map { |sp| Decorators::StudentMember.new(sp.student, sp) }
  end

  private


  # Sets the Project's Unit to be equal to the Assignment's Project before
  # validation to ensure data integrity.
  #
  # @private
  #
  def unit_from_assignment
    self.unit = assignment.unit if assignment && assignment.unit && !persisted?
  end
end
