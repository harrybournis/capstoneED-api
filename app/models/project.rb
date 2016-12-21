class Project < ApplicationRecord
  # Attributes
  # project_name    :string
  # team_name       :string
  # enrollment_key  :string
  # logo            :string
  # assignment_id   :integer

  include Project::Evaluatable,
          Project::Enrollable

	# Associations
  belongs_to  :assignment, inverse_of: :projects
  has_many    :students_projects, class_name: JoinTables::StudentsProject
  has_many    :students, through: :students_projects, dependent: :delete_all
  has_many    :iterations, through: :assignment
  has_one     :lecturer,  through: :assignment
  has_one     :extension

  # Validations
  validates_presence_of 	:project_name, :team_name, :assignment, :description
  validates_uniqueness_of :id, :enrollment_key
  validates_uniqueness_of :project_name, scope: :assignment_id, case_sensitive: false

  before_validation :generate_enrollment_key
end
