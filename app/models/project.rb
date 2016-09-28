class Project < ApplicationRecord
  # Attributes
  # start_date  :date
  # end_date    :date
  # description :text
  # unit_id     :integer
  # lecturer_id :integer

	# Associations
  belongs_to 	:lecturer
  belongs_to 	:unit
  has_many 		:teams, inverse_of: :project, dependent: :destroy
  has_many    :students_teams, through: :teams
  has_many		:students, through: :students_teams
  has_many    :iterations, dependent: :destroy
  has_many    :pa_forms, through: :iterations

  accepts_nested_attributes_for :teams

  # Validations
  validates_presence_of :start_date, :end_date, :description, :unit_id, :lecturer_id
  validate :unit_is_owned_by_lecturer, unless: 'lecturer_id.nil?'
  validates_uniqueness_of :id

	private

		def unit_is_owned_by_lecturer
			unless lecturer.units.include?(unit)
				errors.add(:unit, "does not belong in the Lecturer's list of Units")
			end
		end
end
