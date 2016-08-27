class Lecturer < User
	validates_presence_of :position
	validates_presence_of :university
end
