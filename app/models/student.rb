# One of the two main User classes
class Student < User
  # Attributes
  # first_name  :string
  # last_name   :string
  # email       :string
  # provider    :string (email, facebook)
  # type        :string Student

  # Associations
  has_many  :students_projects, class_name:  StudentsProject
  has_many  :projects, through: :students_projects, dependent: :destroy
  has_many  :assignments, through: :projects
  has_many  :peer_assessments_submitted_by,
            class_name: PeerAssessment,
            foreign_key: :submitted_by_id
  has_many  :peer_assessments_submitted_for,
            class_name: PeerAssessment,
            foreign_key: :submitted_for_id
  has_many  :log_points
  has_many  :peer_assessment_points
  has_one   :student_profile

  validates_absence_of :position, :university
  validates_inclusion_of :type, in: ['Student']

  # Returns all the students in the same teams as the student.
  # The student is excluded by default. By setting with_student to
  # true the student is included in the results
  #
  # @param with_student = false [Boolean] If set to true it will
  #   return teammates with the student included.
  #
  # @return [Array] The students
  #
  def teammates(with_student = false)
    if with_student
      Student.joins(:projects).where('projects.id' => projects.ids)
             .distinct
    else
      Student.joins(:projects).where('projects.id' => projects.ids)
             .where.not(id: id).distinct
    end
  end

  # Returns the student's nickname for the provided project.
  # Returns nil if student can not be found in the project.
  #
  # @param project_id [Integer] The id of the project
  #
  # @return [String | nil] The nickname or nil if student not found.
  #
  def nickname_for_project_id(project_id)
     StudentsProject.select(:nickname)
                               .where(project_id: project_id, student_id: id)[0]
                               .nickname
  rescue
    nil
  end

  # Returns the student's points for the provided project.
  # Returns nil if student can not be found in the project.
  #
  # @param project_id [Integer] The id of the project
  #
  # @return [Integer | nil] The points or nil if student not found.
  #
  def points_for_project_id(project_id)
     StudentsProject.select(:points)
                               .where(project_id: project_id, student_id: id)[0]
                               .points
  rescue
    nil
  end

  # Updates a students points in a project.
  # Returns nil if student can not be found in the project.
  #
  # @param points [Integer] The points to be added.
  # @param project_id [Integer] The id of the project
  #
  # @return [Integer | nil] The new points after adding the new ones, or nil
  #
  def add_points_for_project_id(points, project_id)
    return nil unless sp =  StudentsProject.where(project_id: project_id,
                                                             student_id: id)
                                                      .first
    sp.update(points: sp.points + points)
    sp.valid? ? sp.points : nil
  end
end
