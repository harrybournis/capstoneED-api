class Unit < ApplicationRecord

	# Associations
	belongs_to :lecturer
	belongs_to :department
	has_many :projects
  has_many :teams, through: :projects
  has_many :students_teams, through: :teams
  has_many :students, through: :students_teams

	accepts_nested_attributes_for :department

	# Validations
	validates_presence_of :name, :code, :semester, :year, :lecturer_id
	validates_numericality_of :year
	validates_uniqueness_of :id

	# Class Methods

  # Returns an array of all the associated resources of the Unit.
  # Used in the controller to validate if the ?includes param is valid
  #
  # !Every resource must implement this method!
  def self.associations
    ['lecturer', 'projects', 'department']
  end

  # The database query that associates the Project with the current user
  # Eager loads associated resources if 'includes' is set.
  #
  # !Every resource must implenent this method!
  def self.set_if_owner(unit_id, current_user, includes = nil)
    Unit.where(id: unit_id, lecturer_id: current_user.id).eager_load(includes)[0]
  end
end
