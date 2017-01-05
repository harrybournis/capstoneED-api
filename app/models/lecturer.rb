class Lecturer < User
	# Attributes
	# first_name 	:string
	# last_name		:string
	# email				:string
	# provider		:string (email, facebook etc.)
	# type				:string Lecturer
	# position		:string
	# university	:string

	# Associations
	has_many :units
	has_many :assignments
	has_many :projects, through: :assignments
	has_many :questions, dependent: :destroy

	# Validations
	validates_presence_of :position
	validates_presence_of :university
	validates_inclusion_of :type, in: ['Lecturer']
end
