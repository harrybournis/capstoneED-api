class Includes::ProjectSerializer < ProjectSerializer
	belongs_to 	:assignment
	has_many 		:students
	has_one			:lecturer
end
