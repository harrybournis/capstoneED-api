class Unit < ApplicationRecord
	# Attributes
	# name						:string
	# code						:string
	# semester				:string
	# year						:integer
	# archived_at			:date
	# department_id 	:integer
	# lecturer_id			:integer

	# Associations
	belongs_to :lecturer
	belongs_to :department
	has_many :assignments
  has_many :projects, through: :assignments
  has_many :students_projects, through: :projects
  has_many :students, through: :students_projects

	accepts_nested_attributes_for :department

	# Validations
	validates_presence_of :name, :code, :semester, :year, :lecturer_id
	validates_presence_of :department, message: 'must exist. Either provide a department_id, or deparment_attributes in order to create a new Department'
	validates_numericality_of :year
	validates_uniqueness_of :id
end
