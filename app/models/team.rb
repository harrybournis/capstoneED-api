class Team < ApplicationRecord
  # Attributes
  # name            :string
  # enrollment_key  :string
  # logo            :string
  # project_id      :integer

	# Associations
  belongs_to  :project, inverse_of: :teams
  has_many    :students_teams, class_name: JoinTables::StudentsTeam
  has_many    :students, through: :students_teams, dependent: :delete_all
  has_one     :lecturer,  through: :project

  # Validations
  validates_presence_of 	:name, :project
  validates_uniqueness_of :id, :enrollment_key
  validates_uniqueness_of :name, scope: :project_id, case_sensitive: false

  before_validation :generate_enrollment_key

  # Instance Methods

  # Add a student to a Team with validations
  def enrol(student)
  	enrolment = JoinTables::StudentsTeam.new(team: self, student: student)

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
          break unless Team.where(enrollment_key: generated_key).any?
        end
        self.enrollment_key = generated_key
      end
    end
end
