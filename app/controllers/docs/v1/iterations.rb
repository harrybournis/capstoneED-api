class Docs::V1::Iterations < ApplicationController

	include Docs::Helpers::DocHelper
	DocHelper = Docs::Helpers::DocHelper

	resource_description do
	  short 'Projects have iterations'
	  name 'Iterations'
	  api_base_url '/v1'
	  api_version 'v1'
	  meta attributes: { name: 'String', start_date: 'Date', deadline: 'Date', lecturer_id: 'Integer' }
	  description <<-EOS
			Each project can have many iterations which are connected with a form. A Lecturer creates
			Iterations for a Project, and Studens must submit peer evaluation forms for each Iteration.
	  EOS
	end

	api :GET, '/iterations?project_id', "Get all Iterations for the project_id"
  meta :authentication? => true
  param :project_id, Integer, 'The project whose Iterations will be returned', required: true
  error code: 400, desc: 'The project_id is missing from the params'
  error code: 401, desc: 'Authentication failed'
  error code: 403, desc: 'The project_id does not belong to a project associated with current_user'
  example DocHelper.format_example(status = 200, nil, body = "{\n  \"iterations\": [\n    {\n      \"id\": 6,\n      \"name\": \"Testing\",\n      \"start_date\": \"2017-01-06T22:15:35.402Z\",\n      \"deadline\": \"2018-02-08T02:52:33.222Z\",\n      \"pa_form\": null\n    },\n    {\n      \"id\": 7,\n      \"name\": \"Analysis\",\n      \"start_date\": \"2016-11-13T14:07:52.884Z\",\n      \"deadline\": \"2016-11-15T14:07:52.884Z\",\n      \"pa_form\": {\n        \"id\": 2,\n        \"iteration_id\": 7,\n        \"questions\": [\n          {\n            \"text\": \"What?\",\n            \"question_id\": 1\n          },\n          {\n            \"text\": \"Who?\",\n            \"question_id\": 2\n          },\n          {\n            \"text\": \"When?\",\n            \"question_id\": 3\n          },\n          {\n            \"text\": \"Where?\",\n            \"question_id\": 4\n          },\n          {\n            \"text\": \"Why?\",\n            \"question_id\": 5\n          }\n        ],\n        \"start_date\": \"2016-11-17T16:07:52.000+02:00\",\n        \"deadline\": \"2016-11-20T16:07:52.000+02:00\"\n      }\n    },\n    {\n      \"id\": 8,\n      \"name\": \"Testing\",\n      \"start_date\": \"2016-11-14T14:07:52.884Z\",\n      \"deadline\": \"2016-11-16T14:07:52.884Z\",\n      \"pa_form\": {\n        \"id\": 3,\n        \"iteration_id\": 8,\n        \"questions\": [\n          {\n            \"text\": \"What?\",\n            \"question_id\": 1\n          },\n          {\n            \"text\": \"Who?\",\n            \"question_id\": 2\n          },\n          {\n            \"text\": \"When?\",\n            \"question_id\": 3\n          },\n          {\n            \"text\": \"Where?\",\n            \"question_id\": 4\n          },\n          {\n            \"text\": \"Why?\",\n            \"question_id\": 5\n          }\n        ],\n        \"start_date\": \"2016-11-18T16:07:52.000+02:00\",\n        \"deadline\": \"2016-11-21T16:07:52.000+02:00\",\n        \"extensions\": [\n          {\n            \"id\": 1,\n            \"team_id\": 9,\n            \"deliverable_id\": 3,\n            \"created_at\": \"2016-11-10T14:07:53.043Z\",\n            \"updated_at\": \"2016-11-10T14:07:53.043Z\",\n            \"extra_time\": 172800\n          }\n        ]\n      }\n    },\n    {\n      \"id\": 9,\n      \"name\": \"Implementation\",\n      \"start_date\": \"2016-11-14T14:07:52.884Z\",\n      \"deadline\": \"2016-11-16T15:07:52.884Z\",\n      \"pa_form\": {\n        \"id\": 4,\n        \"iteration_id\": 9,\n        \"questions\": [\n          {\n            \"text\": \"What?\",\n            \"question_id\": 1\n          },\n          {\n            \"text\": \"Who?\",\n            \"question_id\": 2\n          },\n          {\n            \"text\": \"When?\",\n            \"question_id\": 3\n          },\n          {\n            \"text\": \"Where?\",\n            \"question_id\": 4\n          },\n          {\n            \"text\": \"Why?\",\n            \"question_id\": 5\n          }\n        ],\n        \"start_date\": \"2016-11-18T17:07:52.000+02:00\",\n        \"deadline\": \"2016-11-21T17:07:52.000+02:00\",\n        \"extensions\": [\n          {\n            \"id\": 2,\n            \"team_id\": 9,\n            \"deliverable_id\": 4,\n            \"created_at\": \"2016-11-10T14:07:53.130Z\",\n            \"updated_at\": \"2016-11-10T14:07:53.130Z\",\n            \"extra_time\": 172800\n          }\n        ]\n      }\n    }\n  ]\n}")
  description <<-EOS
  	Get all predefined questions for a specific project. The current user must be associated
  	with the project. Includes the PAForm by default.
		It there are any extensions for any team for a pa_form, they are included in 'extensions' inside the
		'pa_form' object.
  EOS
  def index_for_project_id
  end

	api :GET, 'iterations/:id', 'Show an Iteration'
  meta :authentication? => true
  param :id, Integer, 'The id of the Iteration to be returned', required: true
  error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'The Iteration is not associated with the current user'
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"iteration\": {\n    \"id\": 8,\n    \"name\": \"Implementation\",\n    \"start_date\": \"2016-12-16T01:55:27.603Z\",\n    \"deadline\": \"2017-12-26T01:12:50.078Z\",\n    \"pa_form\": {\n      \"id\": 5,\n      \"iteration_id\": 8,\n      \"questions\": [\n        {\n          \"text\": \"What?\",\n          \"question_id\": 1\n        },\n        {\n          \"text\": \"Who?\",\n          \"question_id\": 2\n        },\n        {\n          \"text\": \"When?\",\n          \"question_id\": 3\n        },\n        {\n          \"text\": \"Where?\",\n          \"question_id\": 4\n        },\n        {\n          \"text\": \"Why?\",\n          \"question_id\": 5\n        }\n      ]\n    }\n  }\n}")
	description <<-EOS
		Returns an Iteration. Must be associated with the current user. Includes the PAForm by default.
		It there are any extensions for any team for a pa_form, they are included in 'extensions' inside the
		'pa_form' object.
	EOS
	def show_iteration
	end

	api :POST, '/iterations', 'Create a new Iteration resource'
	meta :authentication? => true
  meta :lecturers_only => true
	param :name, 		String, "The name of the Iteration", 		required: true
	param :start_date, 	Date, "The Date that it starts. Must be in the future.",	required: true
	param :deadline, 		Date, "The Deadline for submitting this Iteration. Must be after the start_date parameter.", required: true
	param :project_id, Integer, "The Project that this Iteration belongs to", required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a Lecturer'
  error code: 403, desc: 'The project_id does not belong to a project associated with current_user'
	error code: 422, desc: "Params are missing or are invalid. Start Date must be sometime AFTER the current time, and deadline must be AFTER start_date."
	description <<-EOS
		Create a new Iteration instance for a Project. The
	EOS
	def create_iteration
	end

	api :PATCH, '/iterations/:id', 'Update Iteration'
	meta :authentication? => true
  meta :lecturers_only => true
	param :name, 		String, "The name of the Iteration"
	param :start_date, 	Date, "The Date that it starts. Must be in the future."
	param :deadline, 		Date, "The Deadline for submitting this Iteration. Must be after the start_date parameter."
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'This User is not the owner of this resource'
	error code: 422, desc: "Params are missing or are invalid. Start Date must be sometime AFTER the current time, and deadline must be AFTER start_date."
	description <<-EOS
		Update an Iteration.
	EOS
	def update_iteration
	end

	api :DELETE, '/iterations/:id', 'Delete Iteration'
	meta :authentication? => true
  meta :lecturers_only => true
	param :id, String, 'The id of the Iteration', required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'This User is not the owner of this resource'
	error code: 422, desc: "Params are missing or are invalid. Start Date must be sometime AFTER the current time, and deadline must be AFTER start_date."
	description <<-EOS
		Delete Iteration resource
	EOS
	def destroy_iteration
	end
end
