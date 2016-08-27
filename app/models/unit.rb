class Unit < ApplicationRecord

	# Associations
	belongs_to :lecturer
	belongs_to :department

	# Validations
	validates_presence_of :name
	validates_presence_of :code
	validates_presence_of :semester
	validates_presence_of :year
	validates_presence_of :lecturer_id
	validates_numericality_of :year
end
