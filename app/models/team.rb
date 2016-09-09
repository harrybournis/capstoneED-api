class Team < ApplicationRecord

	# Associations
  belongs_to :project
  has_many :students_teams, class_name: JoinTables::StudentsTeam
  has_many :students, through: :students_teams, dependent: :delete_all
  has_one :lecturer,  through: :project

  # Validations
  validates_presence_of 	:name, :enrollment_key, :project_id
  validates_uniqueness_of :id, :enrollment_key
  validates_uniqueness_of :name, scope: :project_id, case_sensitive: false

  # Class Methods

  # Returns an array of all the associated resources of the Project.
  # Used in the controller to validate if the ?includes param is valid
  #
  # !Every resource must implement this method!
  def self.associations
    ['project', 'students']
  end

  # The database query that associates the Project with the current user
  # Eager loads associated resources if 'includes' is set.
  #
  # !Every resource must implenent this method!
  def self.set_if_owner(team_id, current_user, includes = nil)
    if current_user.type.start_with? 'Student'
      Team.joins(:students_teams).where(["teams.id = ? and students_teams.student_id = ?", team_id, current_user.id]).eager_load(includes)[0]
    else
      Team.joins(:project).where(["teams.id = ? and projects.lecturer_id = ? ", team_id, current_user.id]).eager_load(includes)[0]
    end
  end

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
