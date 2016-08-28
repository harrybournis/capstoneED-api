class Project < ApplicationRecord

	# Associations
  belongs_to :lecturer
  belongs_to :unit

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
