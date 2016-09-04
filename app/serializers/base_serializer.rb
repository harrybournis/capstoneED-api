class BaseSerializer < ActiveModel::Serializer

	def params_include?(resource)
		#binding.pry
		@includes ||= parse_includes
		return @includes.include? resource
	end

	def parse_includes
		scope[:includes].split(',')
	end
end
