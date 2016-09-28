class Docs::V1::PaForms < ApplicationController

	include Docs::Helpers::DocHelper
	DocHelper = Docs::Helpers::DocHelper

	resource_description do
	  short 'Peer Assesment Forms are created by Lecturers.'
	  name 'Peer Assessment Forms'
	  api_base_url '/v1'
	  api_version 'v1'
	  meta attributes: { iteration_id: 'Integer', questions: 'Array' }
	  description <<-EOS
			Lecturers create a Peer Assessment for each Project Iteration. An Iteration has one Peer Assessment.
	  EOS
	end


	api :GET, 'pa_forms/:id', 'Show an Peer Assessment Form'
  meta :authentication? => true
  param :id, Integer, 'The id of the Peer Assessment to be returned', required: true
  error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'The PAForm is not associated with the current user'
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"pa_form\": {\n    \"id\": 1,\n    \"iteration_id\": 1,\n    \"questions\": [\n      {\n        \"text\": \"What?\",\n        \"question_id\": 1\n      },\n      {\n        \"text\": \"Who?\",\n        \"question_id\": 2\n      },\n      {\n        \"text\": \"When?\",\n        \"question_id\": 3\n      },\n      {\n        \"text\": \"Where?\",\n        \"question_id\": 4\n      },\n      {\n        \"text\": \"Why?\",\n        \"question_id\": 5\n      }\n    ]\n  }\n}")
	description <<-EOS
		Returns a Peer Assessment Form. Must be associated with the current user.
	EOS
	def show_peer_assessment_form
	end

	api :POST, '/pa_forms', 'Create a new Peer Assessment resource'
	meta :authentication? => true
  meta :lecturers_only => true
	param :iteration_id, 		Integer, "The id of the iteration. It must belong a project of the current user.", 		required: true
	param :questions, Array, "The Questions of the form. Must be an Array of Strings. e.g. ['Who?', 'What?', 'When?']", required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a Lecturer'
  error code: 403, desc: 'The iteration_id does not belong to a project associated with current_user'
	error code: 422, desc: "Params are missing or are invalid. See errors in the body of the response."
	example DocHelper.format_example(status = 201, nil, body = "{\n  \"pa_form\": {\n    \"id\": 3,\n    \"iteration_id\": 1,\n    \"questions\": [\n      {\n        \"question_id\": 1,\n        \"text\": \"Who is it?\"\n      },\n      {\n        \"question_id\": 2,\n        \"text\": \"Human?\"\n      },\n      {\n        \"question_id\": 3,\n        \"text\": \"Hello?\"\n      },\n      {\n        \"question_id\": 4,\n        \"text\": \"Favorite Power Ranger?\"\n      }\n    ]\n  }\n}", request = "{\n  \"iteration_id\": \"1\",\n  \"questions\": [\n    \"Who is it?\",\n    \"Human?\",\n    \"Hello?\",\n    \"Favorite Power Ranger?\"\n  ]\n}")
	description <<-EOS
		Create a new Peer Assessment Form for an Iteration of a Project. The iteration_id provided must
		belong to a Project of the current_user. Questions must be provided in the form of an Array of
		Strings.
	EOS
	def create_peer_assessment_form
	end

end
