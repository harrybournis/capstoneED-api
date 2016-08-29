class Unit < ApplicationRecord

	# Associations
	belongs_to :lecturer
	belongs_to :department
	has_many :projects

	accepts_nested_attributes_for :department

	# Validations
	validates_presence_of :name, :code, :semester, :year, :lecturer_id
	validates_numericality_of :year
	validates_uniqueness_of :id

end
