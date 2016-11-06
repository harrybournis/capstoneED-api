class Section < ApplicationRecord
  # Attributes
  # name  :string

	# Associations
	has_many :questions_sections
	has_many :questions, through: :questions_sections

  # Validations
  validates_presence_of :name
end
