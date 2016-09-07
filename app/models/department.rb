class Department < ApplicationRecord

	# Associations
	has_many :units

	#Validations
	validates_presence_of :name, :university
	validates_uniqueness_of :id
	validates :name, uniqueness: { scope: :university, message: 'this department already exists for this University', case_sensitive: false }

  # Class Methods

  # Returns an array of all the associated resources of the Project.
  # Used in the controller to validate if the ?includes param is valid
  #
  # !Every resource must implement this method!
  def self.associations
    ['units']
  end

  # The database query that associates the Project with the current user
  # Eager loads associated resources if 'includes' is set.
  #
  # !Every resource must implenent this method!
  def self.set_if_owner(department_id, current_user, includes = nil)
    Department.where(id: department_id, lecturer_id: current_user.id).eager_load(includes)[0]
  end
end
