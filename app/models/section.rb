# A Question belongs to a section
class Section < ApplicationRecord
  # Attributes
  # name  :string

  # Associations
  has_many :questions_sections, class_name:  QuestionsSection
  has_many :questions, through: :questions_sections

  # Validations
  validates_presence_of :name
end
