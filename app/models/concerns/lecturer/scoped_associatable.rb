module Lecturer::ScopedAssociatable

	extend ActiveSupport::Concern

	# For Testing Only
	def scoped_association
		'Lecturer'
	end

	# Returns the projects of the current user
	def projects(options={})
		if options[:includes]
			return nil unless includes_array = validate_includes(project_associations, options[:includes], 'Projects')
		end
		Project.where(lecturer_id: @id).eager_load(includes_array)
	end

	private

		def validate_includes(associations, includes, resource)
			includes_array = includes.split(',')

			unless associations.length < includes_array.length
				valid = true
				includes_array.each { |e| valid = false unless associations.include? e }
				return includes_array if valid
			end
			render json: format_errors({ base: ["Invalid 'includes' parameter. #{resource} resource accepts only: #{Project.associations.join(', ')}. Received: #{params[:includes]}."] }), status: :bad_request
			return nil
		end

		def project_associations
	    ['lecturer', 'unit', 'teams', 'students']
	  end
end
