class Includes::StudentSerializer < StudentSerializer
	has_many :teams
	has_many :projects
end
