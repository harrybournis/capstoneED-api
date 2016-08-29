class Docs::V1::Projects < ApplicationController

	include Docs::Helpers::DocHelper
	DocHelper = Docs::Helpers::DocHelper

	resource_description do
	  short 'Projects belong to Units and have many teams of Students'
	  name 'Projects'
	  api_base_url '/v1'
	  api_version 'v1'
	  description <<-EOS
			Projects belong to Units and have many teams of Students. A Lecturer creates a Project,
			and Students undertake a projects by spliting themselves into teams. A Projects can have many
			Iterations, for each of which the Students are expected to complete peer assessments.
	  EOS
	end

	api :GET, '/projects', "Get the current user's Projects"
  meta :authentication? => true
  param :unit_id, Integer, 'Return all the Projects for a specific Unit.'
  error code: 401, desc: 'Authentication failed'
  error code: 403, desc: 'This User is not the owner of this resource'
  example DocHelper.format_example(status = 200, nil, body =  "{\n  \"projects\": [\n    {\n      \"id\": 402,\n      \"start_date\": \"2016-08-29\",\n      \"end_date\": \"2016-12-12\",\n      \"description\": \"Eos consectetur quidem enim rerum ad. Similique aut fuga suscipit est. Velit et nesciunt placeat earum quam culpa. Cum aut fuga. A et tenetur.\",\n      \"unit\": {\n        \"id\": 1802,\n        \"name\": \"Advanced high-level contingency\",\n        \"code\": \"B0000DGFW7\",\n        \"semester\": \"Spring\",\n        \"year\": 2017,\n        \"archived_at\": null\n      }\n    },\n    {\n      \"id\": 403,\n      \"start_date\": \"2016-08-29\",\n      \"end_date\": \"2017-08-26\",\n      \"description\": \"Et necessitatibus ex dolor et et. Adipisci explicabo harum molestias et aut consequuntur sit. Debitis nihil dolores. Laudantium ratione eveniet dolor.\",\n      \"unit\": {\n        \"id\": 1802,\n        \"name\": \"Advanced high-level contingency\",\n        \"code\": \"B0000DGFW7\",\n        \"semester\": \"Spring\",\n        \"year\": 2017,\n        \"archived_at\": null\n      }\n    }\n  ]\n}")
  description <<-EOS
  	Show all Projects associated with the current user. By passing a unit_id in the params,
  	the Projects returned can be scoped to that Unit. The Unit must belong to the current user.
  	The current user can be either a Lecturer or a Student.
  EOS
  def index
  end

	api :GET, 'projects/:id', 'Show a Project'
  meta :authentication? => true
  param :id, String, 'The id of the Project to be returned', required: true
  error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'This User is not the owner of this resource'
  example DocHelper.format_example(status = 200, nil, body = "{\n  \"project\": {\n    \"id\": 376,\n    \"start_date\": \"2016-08-29\",\n    \"end_date\": \"2016-10-03\",\n    \"description\": \"Quia dolore labore. Aut molestiae necessitatibus et hic vel ullam et. Nam doloribus eum qui recusandae. Atque eos ullam. Odit est consequatur.\",\n    \"unit\": {\n      \"id\": 1774,\n      \"name\": \"Cloned asymmetric Graphical User Interface\",\n      \"code\": \"B0000DHCZT\",\n      \"semester\": \"Spring\",\n      \"year\": 2017,\n      \"archived_at\": null\n    }\n  }\n}")
	example DocHelper.format_example(status = 403, nil, body = "{\n  \"errors\": {\n    \"base\": [\n      \"This Project can not be found in the current user's Projects\"\n    ]\n  }\n}")
	description <<-EOS
		Returns the Project specified by the id in the params. The user can be either a Lecturer or a
		student but they in both cases they have to be associated with the Project.
	EOS
	def show
	end

	api :POST, '/units', 'Create a new Unit resource'
	meta :authentication? => true
	param :start_date, Date, 'Date the Project Started', required: true
	param :end_date, Date, 'Date the Project Ended'
	param :description, String, 'Project description', required: true
	param :unit_id, Integer,'The Unit that the Project belongs to', required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'This User is not the owner of this resource'
	error code: 422, desc: 'Invalid Params'
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"project\": {\n    \"id\": 1133,\n    \"start_date\": \"2016-08-29\",\n    \"end_date\": \"2016-10-16\",\n    \"description\": \"Excepturi quis non minus dolor qui officia. Aperiam ex dolorum libero atque perferendis molestiae quos. Et est quidem. Veniam deleniti provident sit.\",\n    \"unit\": {\n      \"id\": 2839,\n      \"name\": \"Streamlined object-oriented encoding\",\n      \"code\": \"B000FQ9CTY\",\n      \"semester\": \"Autumn\",\n      \"year\": 2016,\n      \"archived_at\": null\n    }\n  }\n}")
	description <<-EOS
		Create a new Project. Only Lecturers can create a Project, and it will automatically be
		associated with the current user. Requires a unit_id, which must be a Unit that belongs to the
		current user.
	EOS
	def create
	end

	api :PATCH, '/projects/:id', 'Update a Unit resource'
	meta :authentication? => true
	param :id, Integer, "The id of the Unit", required: true
	param :start_date, Date, 'Date the Project Started'
	param :end_date, Date, 'Date the Project Ended'
	param :description, String, 'Project description'
	param :unit_id, Integer,'The Unit that the Project belongs to'
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'This User is not the owner of this resource'
	error code: 422, desc: 'Invalid Params'
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"project\": {\n    \"id\": 1134,\n    \"start_date\": \"2016-08-29\",\n    \"end_date\": \"2017-08-29\",\n    \"description\": \"Aspernatur rerum aut. Mollitia quam et. Et magnam atque eaque ducimus magni quia.\",\n    \"unit\": {\n      \"id\": 2845,\n      \"name\": \"Face to face upward-trending workforce\",\n      \"code\": \"B0006DRM02\",\n      \"semester\": \"Autumn\",\n      \"year\": 2017,\n      \"archived_at\": null\n    }\n  }\n}")
	description <<-EOS
		Update a Project
	EOS
	def update
	end

	api :DELETE, '/projects/:id', 'Delete Project'
	meta :authentication? => true
	param :id, Integer, 'The id of the Project to be deleted', required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'This User is not the owner of this resource'
	error code: 422, desc: "Invalid params"
	description <<-EOS
		Delete Project resource. It must belong to the current user.
	EOS
	def destroy
	end
end
