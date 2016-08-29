class Lecturer < User

	# Associations
	has_many :units

	# Validations
	validates_presence_of :position
	validates_presence_of :university
end
