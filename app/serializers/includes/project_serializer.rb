class Includes::ProjectSerializer < ProjectSerializer
  has_one		:unit
  has_many 	:teams
end
