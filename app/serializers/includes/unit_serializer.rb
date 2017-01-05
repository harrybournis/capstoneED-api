class Includes::UnitSerializer < UnitSerializer
	belongs_to 	:department
	has_many 		:assignments
	has_one			:lecturer
end
