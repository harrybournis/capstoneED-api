# A PAform may receive a deadline Extension
class Extension < ApplicationRecord
  # Attributes
  # extra_time      :integer
  # deliverable_id  :integer (alias: pa_form_id)
  # project_id      :integer

  # Validations
  validates_presence_of :extra_time, :deliverable_id, :project_id
  validates_uniqueness_of :deliverable_id,
                          scope: :project_id,
                          message: 'already exists for this project_id'

  # Associations
  belongs_to :pa_form, class_name: PAForm, foreign_key: :deliverable_id
  belongs_to :project
  has_one :assignment, through: :project
  has_many :students_projects, through: :project

  alias_attribute :pa_form_id, :deliverable_id
end
