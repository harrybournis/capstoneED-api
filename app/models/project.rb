class Project < ApplicationRecord
  attr_reader :associations
	# Associations
  belongs_to 	:lecturer
  belongs_to 	:unit
  has_many 		:teams, dependent: :destroy
  has_many		:students, through: :teams

  # Validations
  validates_presence_of :start_date, :end_date, :description, :unit_id, :lecturer_id
  validate :unit_is_owned_by_lecturer, unless: 'lecturer_id.nil?'
  validates_uniqueness_of :id

  # Returns an array of all the associated resources of the Project.
  # Used in the controller to validate if the ?includes param is valid
  #
  # !Every resource must implement this method!
  def self.associations
    ['lecturer', 'unit', 'teams', 'students']
  end

  # Methods
  def self.set_if_owner(project_id, user_id, includes = nil)
    Project.where(id: project_id, lecturer_id: user_id).eager_load(includes)[0]
  end

	private

		def unit_is_owned_by_lecturer
			unless lecturer.units.include?(unit)
				errors.add(:unit, "does not belong in the Lecturer's list of Units")
			end
		end
end
