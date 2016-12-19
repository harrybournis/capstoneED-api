class Project < ApplicationRecord
  # Attributes
  # project_name    :string
  # team_name       :string
  # enrollment_key  :string
  # logo            :string
  # assignment_id   :integer

	# Associations
  belongs_to  :assignment, inverse_of: :projects
  has_many    :students_projects, class_name: JoinTables::StudentsProject
  has_many    :students, through: :students_projects, dependent: :delete_all
  has_one     :lecturer,  through: :assignment
  has_one     :extension

  # Validations
  validates_presence_of 	:project_name, :team_name, :assignment, :description
  validates_uniqueness_of :id, :enrollment_key
  validates_uniqueness_of :project_name, scope: :assignment_id, case_sensitive: false

  before_validation :generate_enrollment_key

  # Instance Methods

  # Add a student to a Team with validations
  def enrol(student)
  	enrolment = JoinTables::StudentsProject.new(project: self, student: student)

  	if enrolment.save
  		true
  	else
			enrolment.errors.full_messages.each { |error| errors[:base] << error }
			false
		end
  end


  private

    def generate_enrollment_key
      unless enrollment_key.present?
        generated_key = nil
        loop do
          generated_key = SecureRandom.base64(32)
          break unless Project.where(enrollment_key: generated_key).any?
        end
        self.enrollment_key = generated_key
      end
    end
end
