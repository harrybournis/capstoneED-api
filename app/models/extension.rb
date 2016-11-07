class Extension < ApplicationRecord
	# Attributes
	# extra_time 			:integer
	# form_id					:integer
	# iteration_id		:integer

	# Validations
	validates_presence_of :extra_time, :iteration_id, :team_id
	validates_uniqueness_of :iteration_id, scope: :team_id, message: 'already exists for this team_id'

	# Associations
	belongs_to :iteration
	belongs_to :team


	# Instance Methods

	# extra_time
	# 172800 2 days in integer
	# Time.at(DateTime.now.to_i + 172800).to_datetime
end
