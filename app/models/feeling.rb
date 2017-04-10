## Used for Project Assessment
class Feeling < ApplicationRecord
  # Attributes
  # name    :string
  # value 	:integer

  # Validations
  validates_presence_of :name, :value
  validates_uniqueness_of :name
  validates_inclusion_of :value, in: 0..1 # feelings are either positive or negative

  # Associations
  has_many :project_evaluations
end
