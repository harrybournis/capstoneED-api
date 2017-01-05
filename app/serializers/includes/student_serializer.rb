class Includes::StudentSerializer < StudentSerializer
	has_many :projects
	has_many :assignments
	type :student
end
