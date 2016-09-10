class Question::CustomQuestion < Question::Question
	# Attributes: category(string), text(string), lecturer_id(integer), type(string)

	# Associations
	belongs_to :lecturer

	# Validations
	validates_presence_of :type, :text, :category, :lecturer_id
end
