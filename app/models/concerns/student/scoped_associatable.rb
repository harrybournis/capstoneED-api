module Student::ScopedAssociatable

	extend ActiveSupport::Concern

	# For Testing only
	def scoped_association
		'Student'
	end
end
