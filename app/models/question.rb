class Question < ApplicationRecord
	# Attributes: category(string), text(string), lecturer_id(integer), type(string)

	# Associations
	belongs_to :lecturer

	# Validations
	validates_presence_of :text, :category, :lecturer_id
	#validates_includes_of :category, in: %w(Question Comment)
end
