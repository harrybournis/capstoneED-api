class Team < ApplicationRecord

	# Associations
  belongs_to :project
  has_many :students_teams, class_name: JoinTables::StudentsTeam, dependent: :destroy
  has_many :students, through: :students_teams

  # Validations
  validates_presence_of 	:name, :enrollment_key, :project_id
  validates_uniqueness_of :id, :enrollment_key
  validates_uniqueness_of :name, scope: :project_id, case_sensitive: false

  # Instance Methods
  def enrol(student)
  	enrolment = JoinTables::StudentsTeam.new(team: self, student: student)

  	if enrolment.save
  		true
  	else
			enrolment.errors.full_messages.each { |error| errors[:base] << error }
			false
		end
  end
end
