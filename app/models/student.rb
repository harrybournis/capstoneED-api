# One of the two main User classes
class Student < User
  # Attributes
  # first_name  :string
  # last_name   :string
  # email       :string
  # provider    :string (email, facebook)
  # type        :string Student

  # Associations
  has_many  :students_projects, class_name: JoinTables::StudentsProject
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

  # Validations
  validates_absence_of :position, :university
  validates_inclusion_of :type, in: ['Student']

  # returns all the Students that share a Team with self
  def teammates
    Student.joins(:projects).where('projects.id' => projects.ids)
           .where.not(id: id).distinct
  end

  # returns the Student's nickname for the provided project
  # Returns nil if no nickname is found
  def nickname_for_project_id(project_id)
    JoinTables::StudentsProject.select(:nickname)
                               .where(project_id: project_id, student_id: id)[0]
                               .nickname
  rescue
    nil
  end

  # returns the student's points for the provided project
  # Returns nil if the project is not found
  def points_for_project_id(project_id)
    JoinTables::StudentsProject.select(:points)
                               .where(project_id: project_id, student_id: id)[0]
                               .points
  rescue
    nil
  end
end
