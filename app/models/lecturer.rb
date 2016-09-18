class Lecturer < User

	# Associations
	has_many :units
	has_many :projects
	has_many :teams, through: :projects
	has_many :questions, dependent: :destroy

	# Validations
	validates_presence_of :position
	validates_presence_of :university
	validates_inclusion_of :type, in: ['Lecturer']
end
