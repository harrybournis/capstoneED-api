class Question < ApplicationRecord
	# Attributes
	# category 			:string
	# text					:string
	# lecturer_id		:integer

	# Associations
	belongs_to :lecturer
	has_many :questions_sections
	has_many :sections, through: :questions_sections

	# Validations
	validates_presence_of :text, :category, :lecturer_id
	#validates_includes_of :category, in: %w(Question Comment)
end
