class Lecturer < User

	# Associations
	has_many :units
	has_many :projects
	has_many :teams, through: :projects

	# Validations
	validates_presence_of :position
	validates_presence_of :university
end
