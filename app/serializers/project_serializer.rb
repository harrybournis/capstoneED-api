class ProjectSerializer < BaseSerializer
  attributes :id, :start_date, :end_date, :description

	has_one		:unit,		if: -> { scope[:includes] && params_include?('unit') 	}
	has_many 	:teams, 	if: -> { scope[:includes] && params_include?('teams') 	}

  attribute :href

	def href
		"/projects/#{object.id}"
	end
end
