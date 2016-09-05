class Includes::UnitsController < UnitsController
	belongs_to 	:department
	has_many 		:projects
end
