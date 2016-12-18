class Assignment < ApplicationRecord
  # Attributes
  # start_date  :date
  # end_date    :date
  # description :text
  # unit_id     :integer
  # lecturer_id :integer

	# Associations
  belongs_to 	:lecturer
  belongs_to 	:unit
  has_many 		:projects, inverse_of: :assignment, dependent: :destroy
  has_many    :students_projects, through: :projects
  has_many		:students, through: :students_projects
  has_many    :iterations, dependent: :destroy
  has_many    :pa_forms, through: :iterations

  accepts_nested_attributes_for :projects

  # Validations
  validates_presence_of :start_date, :end_date, :description, :unit_id, :lecturer_id
  validate :unit_is_owned_by_lecturer, unless: 'lecturer_id.nil?'
  validates_uniqueness_of :id

	private

    # unit validation
		def unit_is_owned_by_lecturer
			unless lecturer.units.include?(unit)
				errors.add(:unit, "does not belong in the Lecturer's list of Units")
			end
		end
end
