class Student < User

	# Validations
	#validate :lecturer_fields_are_nil


	### Instance Methods
	#

	# Silently don't allow university or position to be assigned a value
	def university=(value) 	nil 	; end

	def position=(value) 		nil 	; end
end
