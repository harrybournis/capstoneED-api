class Includes::LecturerSerializer < LecturerSerializer
	has_many :units
	has_many :assignments
end
