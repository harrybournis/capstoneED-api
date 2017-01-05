class Docs::V1::Assignments < ApplicationController

	include Docs::Helpers::DocHelper
	DocHelper = Docs::Helpers::DocHelper

	resource_description do
	  short 'Assignments belong to Units and have many teams of Students'
	  name 'Assignments'
	  api_base_url '/v1'
	  api_version 'v1'
	  meta attributes: { start_date: 'Date', end_date: 'Date', description: 'String' }
	  description <<-EOS
			Assignments belong to Units and have many teams of Students. A Lecturer creates a Assignment,
			and Students undertake a assignments by spliting themselves into teams. A Assignments can have many
			Iterations, for each of which the Students are expected to complete peer assessments.
	  EOS
	end

	api :GET, '/assignments', "Get the current user's Assignments"
  meta :authentication? => true
  meta :includes => true
  param :unit_id, Integer, 'Return all the Assignments for a specific Unit.'
  param :includes, String,	DocHelper.param_includes_text('assignment_associations')
  error code: 400, desc: "Invalid 'includes' parameter."
  error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a Lecturer. Only if the params contained a unit_id and current_user is a Student.'
  error code: 403, desc: 'Current User is not associated with this resource'
  example DocHelper.format_example(status = 200, nil, body =  "{\n  \"assignments\": [\n    {\n      \"id\": 402,\n      \"start_date\": \"2016-08-29\",\n      \"end_date\": \"2016-12-12\",\n      \"description\": \"Eos consectetur quidem enim rerum ad. Similique aut fuga suscipit est. Velit et nesciunt placeat earum quam culpa. Cum aut fuga. A et tenetur.\",\n      \"unit\": {\n        \"id\": 1802,\n        \"name\": \"Advanced high-level contingency\",\n        \"code\": \"B0000DGFW7\",\n        \"semester\": \"Spring\",\n        \"year\": 2017,\n        \"archived_at\": null\n      }\n    },\n    {\n      \"id\": 403,\n      \"start_date\": \"2016-08-29\",\n      \"end_date\": \"2017-08-26\",\n      \"description\": \"Et necessitatibus ex dolor et et. Adipisci explicabo harum molestias et aut consequuntur sit. Debitis nihil dolores. Laudantium ratione eveniet dolor.\",\n      \"unit\": {\n        \"id\": 1802,\n        \"name\": \"Advanced high-level contingency\",\n        \"code\": \"B0000DGFW7\",\n        \"semester\": \"Spring\",\n        \"year\": 2017,\n        \"archived_at\": null\n      }\n    }\n  ]\n}")
  description <<-EOS
  	Show all Assignments associated with the current user. A Lecturer can pass a unit_id in the params,
  	and the Assignments returned can be scoped to that Unit. The Unit must belong to the current user.
  	Including a unit_id if current_user is a Student will result in an error.
  EOS
  def index
  end

	api :GET, 'assignments/:id', 'Show a Assignment'
  meta :authentication? => true
  meta :includes => true
  param :id, Integer, 'The id of the Assignment to be returned', required: true
  param :includes, String,	DocHelper.param_includes_text('assignment_associations')
  error code: 400, desc: "Invalid 'includes' parameter."
  error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not associated with this resource'
  example DocHelper.format_example(status = 200, nil, body = "{\n  \"assignment\": {\n    \"id\": 376,\n    \"start_date\": \"2016-08-29\",\n    \"end_date\": \"2016-10-03\",\n    \"description\": \"Quia dolore labore. Aut molestiae necessitatibus et hic vel ullam et. Nam doloribus eum qui recusandae. Atque eos ullam. Odit est consequatur.\",\n    \"unit\": {\n      \"id\": 1774,\n      \"name\": \"Cloned asymmetric Graphical User Interface\",\n      \"code\": \"B0000DHCZT\",\n      \"semester\": \"Spring\",\n      \"year\": 2017,\n      \"archived_at\": null\n    }\n  }\n}")
	example DocHelper.format_example(status = 403, nil, body = "{\n  \"errors\": {\n    \"base\": [\n      \"This Assignment can not be found in the current user's Assignments\"\n    ]\n  }\n}")
	description <<-EOS
		Returns the Assignment specified by the id in the params. The user can be either a Lecturer or a
		student but they in both cases they have to be associated with the Assignment.
	EOS
	def show
	end

	api :POST, '/assignments', 'Create a new Assignment resource'
	meta :authentication? => true
	param :start_date, Date, 'Date the Assignment Started', required: true
	param :end_date, Date, 'Date the Assignment Ended'
	param :description, String, 'Assignment description', required: true
	param :unit_id, Integer,'The Unit that the Assignment belongs to', required: true
	param :teams_attributes, Hash, 'Create Teams for this Assignment. Format: "teams_attributes": [{ "name": "Team Name", "enrollment_key": "Key" }, { "name": "Team Name 2", "enrollment_key": "Key2" }]. See Examples for more information.'
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'Current User is not associated with this resource'
	error code: 422, desc: 'Invalid Params'
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"assignment\": {\n    \"id\": 1133,\n    \"start_date\": \"2016-08-29\",\n    \"end_date\": \"2016-10-16\",\n    \"description\": \"Excepturi quis non minus dolor qui officia. Aperiam ex dolorum libero atque perferendis molestiae quos. Et est quidem. Veniam deleniti provident sit.\",\n    \"unit\": {\n      \"id\": 2839,\n      \"name\": \"Streamlined object-oriented encoding\",\n      \"code\": \"B000FQ9CTY\",\n      \"semester\": \"Autumn\",\n      \"year\": 2016,\n      \"archived_at\": null\n    }\n  }\n}")
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"assignment\": {\n    \"id\": 10,\n    \"start_date\": \"2016-09-18\",\n    \"end_date\": \"2017-03-22\",\n    \"description\": \"Lorem ipsum dolor sit amet, pri in erant detracto antiopam, duis altera nostrud id eam. Feugait invenire ut vim, novum reprimique reformidans id vis, sit at quis hinc liberavisse. Eam ex sint elaboraret assueverit, sed an equidem reformidans, idque doming ut quo. Ex aperiri labores has, dolorem indoctum hendrerit has cu. At case posidonium pri.\",\n    \"href\": \"/assignments/10\",\n    \"teams\": [\n      {\n        \"id\": 2,\n        \"name\": \"New Team2\",\n        \"logo\": null,\n        \"enrollment_key\": \"key2\"\n      },\n      {\n        \"id\": 1,\n        \"name\": \"New Team1\",\n        \"logo\": null,\n        \"enrollment_key\": \"key\"\n      }\n    ]\n  }\n}", request = "{\n  \"description\": \"Lorem ipsum dolor sit amet, pri in erant detracto antiopam, duis altera nostrud id eam. Feugait invenire ut vim, novum reprimique reformidans id vis, sit at quis hinc liberavisse. Eam ex sint elaboraret assueverit, sed an equidem reformidans, idque doming ut quo. Ex aperiri labores has, dolorem indoctum hendrerit has cu. At case posidonium pri.\",\n  \"end_date\": \"2017-03-22\",\n  \"lecturer\": \"18\",\n  \"lecturer_id\": \"18\",\n  \"start_date\": \"2016-09-18\",\n \"unit_id\": \"7\",\n \"teams_attributes\": [\n    {\n      \"enrollment_key\": \"key\",\n      \"name\": \"New Team1\"\n    },\n    {\n      \"enrollment_key\": \"key2\",\n      \"name\": \"New Team2\"\n    }\n  ] \n}")
	description <<-EOS
		Create a new Assignment. Only Lecturers can create a Assignment, and it will automatically be
		associated with the current user. Requires a unit_id, which must be a Unit that belongs to the
		current user. Can also create multiple Teams through the same request. See examples.
	EOS
	def create
	end

	api :PATCH, '/assignments/:id', 'Update a Assignment resource'
	meta :authentication? => true
	param :id, Integer, "The id of the Unit", required: true
	param :start_date, Date, 'Date the Assignment Started'
	param :end_date, Date, 'Date the Assignment Ended'
	param :description, String, 'Assignment description'
	param :unit_id, Integer,'The Unit that the Assignment belongs to'
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'Current User is not associated with this resource'
	error code: 422, desc: 'Invalid Params'
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"assignment\": {\n    \"id\": 1134,\n    \"start_date\": \"2016-08-29\",\n    \"end_date\": \"2017-08-29\",\n    \"description\": \"Aspernatur rerum aut. Mollitia quam et. Et magnam atque eaque ducimus magni quia.\",\n    \"unit\": {\n      \"id\": 2845,\n      \"name\": \"Face to face upward-trending workforce\",\n      \"code\": \"B0006DRM02\",\n      \"semester\": \"Autumn\",\n      \"year\": 2017,\n      \"archived_at\": null\n    }\n  }\n}")
	description <<-EOS
		Update a Assignment
	EOS
	def update
	end

	api :DELETE, '/assignments/:id', 'Delete Assignment'
	meta :authentication? => true
	param :id, Integer, 'The id of the Assignment to be deleted', required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'Current User is not associated with this resource'
	error code: 422, desc: "Invalid params"
	description <<-EOS
		Delete Assignment resource. It must belong to the current user.
	EOS
	def destroy
	end
end
