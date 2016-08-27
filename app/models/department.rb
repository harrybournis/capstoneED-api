class Department < ApplicationRecord

	#Validations
	validates_presence_of :university
	validates_presence_of :name
	validates :name, uniqueness: { scope: :university, message: 'this department already exists for this University' }
end
