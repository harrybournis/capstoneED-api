module Docs::Helpers::DocHelper

	def self.format_example(status, headers = nil, body = nil)
		status_hash = {
			200 => 'Created',
			204 => 'No Content',
			400 => 'Bad Request',
			401 => 'Unauthorized',
			403 => 'Forbidden',
			422 => 'Unprocessable Entity'
		}
		body ||= "{ \n}"
		headers ||= "{\n  \"X-Frame-Options\": \"SAMEORIGIN\",\n  \"X-XSS-Protection\": \"1; mode=block\",\n  \"X-Content-Type-Options\": \"nosniff\",\n  \"Content-Type\": \"application/json; charset=utf-8\"\n}"

		"Status: #{status} #{status_hash[status]} \nHeaders: \n#{headers} \nBody: \n#{body}"
	end

end
