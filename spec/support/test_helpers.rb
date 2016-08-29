module TestHelpers

	def parse_body
		JSON.parse(response.body)
	end

end
