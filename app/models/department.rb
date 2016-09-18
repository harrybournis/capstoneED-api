class Department < ApplicationRecord

	# Associations
	has_many :units
	has_one :lecturer, through: :units

	#Validations
	validates_presence_of :name, :university
	validates_uniqueness_of :id
	validates :name, uniqueness: { scope: :university, message: 'this department already exists for this University', case_sensitive: false }
end
