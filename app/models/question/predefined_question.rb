class Question::PredefinedQuestion < Question::Question
	# Attributes: category(string), text(string), type(string)

	# Validations
	validates_presence_of :type, :text, :category
	validates_absence_of :lecturer_id
end
