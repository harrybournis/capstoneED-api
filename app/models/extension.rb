class Extension < ApplicationRecord
	# Attributes
	# extra_time 			:integer
	# form_id					:integer
	# deliverable_id		:integer

	# Validations
	validates_presence_of :extra_time, :deliverable_id, :team_id
	validates_uniqueness_of :deliverable_id, scope: :team_id, message: 'already exists for this team_id'

	# Associations
	belongs_to :pa_form, class_name: PAForm, foreign_key: :deliverable_id
	belongs_to :team
	has_one :project, through: :team
	has_many :students_teams, through: :team


	# Instance Methods

	# extra_time
	# 172800 2 days in integer
	# Time.at(DateTime.now.to_i + 172800).to_datetime
end
