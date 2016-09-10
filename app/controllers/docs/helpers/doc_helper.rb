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

	def self.param_includes_text(association)
		"Associations to be returned. Must be separated with a comma. Accepted Vales: Student => #{JWTAuth::CurrentUserStudent.new(nil,nil,nil).send(association)}, Lecturer => #{JWTAuth::CurrentUserLecturer.new(nil,nil,nil).send(association)}"
	end

	def self.label_class_for_error(error)
      case error[:code]
	      when 200
	        'label label-info'
	      when 201
	        'label label-success'
	      when 204
	        'label label-info2'
	      when 400
	      	'label label-warning3'
	      when 401
	        'label label-warning'
	      when 403
	        'label label-warning2'
	      when 422
	        'label label-important'
	      when 404
	        'label label-inverse'
	      else
	        'label'
	    end
	end

end
