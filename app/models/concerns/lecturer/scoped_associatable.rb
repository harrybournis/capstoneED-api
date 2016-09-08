module Lecturer::ScopedAssociatable

	extend ActiveSupport::Concern

	# For Testing Only
	def scoped_association
		'Lecturer'
	end
end
