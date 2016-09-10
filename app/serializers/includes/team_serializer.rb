class Includes::TeamSerializer < TeamSerializer
	belongs_to 	:project
	has_many 		:students
	has_one			:lecturer
end
