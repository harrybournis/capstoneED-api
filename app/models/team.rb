class Team < ApplicationRecord

	# Associations
  belongs_to :project

  # Validations
  validates_presence_of :name, :enrollment_key, :project_id
  validates_uniqueness_of :id, :enrollment_key
end
