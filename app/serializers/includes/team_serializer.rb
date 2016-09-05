class Includes::TeamSerializer < TeamSerializer
	belongs_to 	:project
	has_many 		:students
end
