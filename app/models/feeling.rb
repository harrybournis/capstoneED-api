class Feeling < ApplicationRecord
	# Attributes
	# name 		:string

	# Validations
	validates_presence_of :name
	validates_uniqueness_of :name

	# Associations
	has_many :project_evaluations
end
