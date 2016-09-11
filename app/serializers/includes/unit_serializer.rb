class Includes::UnitSerializer < UnitSerializer
	belongs_to 	:department
	has_many 		:projects
	has_one			:lecturer
end
