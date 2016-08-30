class Team < ApplicationRecord

	# Associations
  belongs_to :project
  has_many :students_teams, class_name: JoinTables::StudentsTeam
  has_many :students, through: :students_teams

  # Validations
  validates_presence_of 	:name, :enrollment_key, :project_id
  validates_uniqueness_of :id, :enrollment_key
end
