class Extension < ApplicationRecord
	# Attributes
	# extra_time 			:integer
	# form_id					:integer
	# deliverable_id	:integer
	# project_id			:integer

	# Validations
	validates_presence_of :extra_time, :deliverable_id, :project_id
	validates_uniqueness_of :deliverable_id, scope: :project_id, message: 'already exists for this project_id'

	# Associations
	belongs_to :pa_form, class_name: PAForm, foreign_key: :deliverable_id
	belongs_to :project
	has_one :assignment, through: :project
	has_many :students_projects, through: :project


	# Instance Methods

	# extra_time
	# 172800 2 days in integer
	# Time.at(DateTime.now.to_i + 172800).to_datetime
end
