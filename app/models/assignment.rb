## A Unit has many assignments. Each Assignment has many Projects.
class Assignment < ApplicationRecord
  # Attributes
  # start_date  :date
  # end_date    :date
  # name        :string
  # unit_id     :integer
  # lecturer_id :integer

  # Associations
  belongs_to 	:lecturer
  belongs_to 	:unit
  has_many :projects, inverse_of: :assignment, dependent: :destroy
  has_many :students_projects, through: :projects
  has_many :students, through: :students_projects
  has_many :iterations, dependent: :destroy
  has_many :pa_forms, through: :iterations

  accepts_nested_attributes_for :projects

  # Validations
  validates_presence_of :start_date, :end_date, :name, :unit_id, :lecturer_id
  validate :unit_is_owned_by_lecturer, unless: 'lecturer_id.nil?'
  validates_uniqueness_of :id

  after_initialize :set_default_values

  attr_writer :project_counter

  # return the number of projects. If it has not persisted, return 0
  def project_counter
    persisted? ? projects.count : @project_counter
  end

  private

  # unit validation
  def unit_is_owned_by_lecturer
    #return if lecturer.units.include?(unit)
    unless lecturer.units.include? unit
      errors.add(:unit, "does not belong in the Lecturer's list of Units")
    end
  end

  # sets default values after initialization
  def set_default_values
    @project_counter = 0
  end
end
