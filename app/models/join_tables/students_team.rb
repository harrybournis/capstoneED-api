class JoinTables::StudentsTeam < ApplicationRecord
	belongs_to :student
	belongs_to :team
end
