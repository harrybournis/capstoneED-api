class Lecturer < User

	# Associations
	has_many :units
	has_many :projects
	has_many :teams, through: :projects
	has_many :custom_questions, dependent: :destroy

	# Validations
	validates_presence_of :position
	validates_presence_of :university
end
