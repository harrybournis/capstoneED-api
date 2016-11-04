class Docs::V1::Units < ApplicationController

	include Docs::Helpers::DocHelper
	DocHelper = Docs::Helpers::DocHelper

	resource_description do
	  short 'Units are created by Lecturers'
	  name 'Units'
	  api_base_url '/v1'
	  api_version 'v1'
	  meta attributes: { name: 'String', code: 'String', semester: 'String', year: 'Integer', archived_at: 'Date' }
	  description <<-EOS
			A Unit is created by a Lecturer and can have many Projects. A Unit also belongs to a Department.
			Archived at?
	  EOS
	end

	api :GET, '/units', "Get the current user's units"
  meta :authentication? => true
  meta :includes => true
  param :includes, String,	DocHelper.param_includes_text('unit_associations')
  error code: 400, desc: "Invalid 'includes' parameter."
  error code: 401, desc: 'Authentication failed'
  example DocHelper.format_example(status = 200, nil, body = "{\n  \"units\": [\n    {\n      \"id\": 1034,\n      \"name\": \"Open-source optimal moratorium\",\n      \"code\": \"B000AR9H5C\",\n      \"semester\": \"Spring\",\n      \"year\": 2017,\n      \"archived_at\": null\n    },\n    {\n      \"id\": 1035,\n      \"name\": \"Cross-group modular system engine\",\n      \"code\": \"B000GWGJK2\",\n      \"semester\": \"Spring\",\n      \"year\": 2016,\n      \"archived_at\": null\n    }\n  ]\n}")
  description <<-EOS
  	Show all Units associated with the current user. Must be logged in as a Lecturer.
  EOS
  def index
  end

	api :GET, 'units/:id', 'Show a Unit'
  meta :authentication? => true
  meta :includes => true
  param :id, String, 'The id of the Unit to be returned', required: true
  param :includes, String,	DocHelper.param_includes_text('unit_associations')
  error code: 400, desc: "Invalid 'includes' parameter."
  error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'This User is not the owner of this resource'
  example DocHelper.format_example(status = 200, nil, body = "{\n  \"unit\": {\n    \"id\": 1042,\n    \"name\": \"Enhanced methodical conglomeration\",\n    \"code\": \"B0002GM6DQ\",\n    \"semester\": \"Spring\",\n    \"year\": 2017,\n    \"archived_at\": null\n  }\n}")
	example DocHelper.format_example(status = 403, nil, body = "{\n  \"errors\": {\n    \"base\": [\n      \"This Unit can not be found in the current user's Units\"\n    ]\n  }\n}")
	description <<-EOS
		Returns the Unit specified by the id in the params. The User must be logged in, a Lecturer,
		and the Unit must belong to them.
	EOS
	def show
	end

	api :POST, '/units', 'Create a new Unit resource'
	meta :authentication? => true
  meta :lecturers_only => true
	param :name, String, 'Name of the Unit', required: true
	param :code, String, 'A code that identifies the Unit within the university. Provided by Lecturer.', required: true
	param :semester, String, 'The semester that this Unit currently takes place. Commonly: [Spring, Autumn]', required: true
	param :year, Integer,'The academic year', required: true
	param :archived_at, Date, 'The Date it was archived'
	param :department_id, Integer, 'If supplied, it associated the Unit with an existing Department. If not supplied, then the department_attributes param must be present instead.'
	param :department_attributes, Hash, 'If supplied, it creates a new Department, and associated it with the Unit. If not supplied, then the department_id param must be present instead.'
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'This User is not the owner of this resource'
	error code: 422, desc: 'Invalid Params'
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"unit\": {\n    \"id\": 1,\n    \"name\": \"Unit 604\",\n    \"code\": \"737B8\",\n    \"semester\": \"Spring\",\n    \"year\": 2015,\n    \"archived_at\": null,\n    \"department\": {\n      \"id\": 1,\n      \"university\": \"university\",\n      \"name\": \"departmentname\"\n    }\n  }\n}", request = "{\n  \"archived_at\": \"\",\n  \"code\": \"JD938D93\",\n  \"department_attributes\": {\n    \"name\": \"departmentname\",\n    \"university\": \"university\"\n  },\n  \"name\": \"Unit 604\",\n  \"semester\": \"Spring\",\n  \"year\": \"2015\" \n}")
	example DocHelper.format_example(status = 422, nil, body = "{\n  \"errors\": {\n    \"department.university\": [\n      \"can't be blank\"\n    ]\n  }\n}")
	description <<-EOS
		Create a new Unit. A Unit belongs to a Department. If a department_id is supplied in the params,
		the unit will become associated with an existing Department. If department_attributes are present,
		then a new Department will be created and associated with the Unit. In case both department_id, and
		department_attributes are present, the department_id takes precedence, and the new Unit is associated
		with an existing Department.
	EOS
	def create
	end

	api :PATCH, '/units/:id', 'Update a Unit resource'
	meta :authentication? => true
	param :id, Integer, "The id of the Unit", required: true
	param :name, String, 'Name of the Unit'
	param :code, String, 'A code that identifies the Unit within the university. Provided by Lecturer.'
	param :semester, String, 'The semester that this Unit currently takes place. Commonly: [Spring, Autumn]'
	param :year, Integer,'The academic year'
	param :archived_at, Date, 'The Date it was archived'
	param :department_id, Integer, 'If supplied, it associated the Unit with an existing Department. If not supplied, then the department_attributes param must be present instead.'
	param :department_attributes, Hash, 'If supplied, it creates a new Department, and associated it with the Unit. If not supplied, then the department_id param must be present instead.'
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'This User is not the owner of this resource'
	error code: 422, desc: 'Invalid Params'
	example DocHelper.format_example(status = 200, headers = "{\n  \"unit\": {\n    \"id\": 1130,\n    \"name\": \"different\",\n    \"code\": \"different\",\n    \"semester\": \"Spring\",\n    \"year\": 2016,\n    \"archived_at\": null\n  }\n}")
	example DocHelper.format_example(status = 403, nil, body = "{\n  \"errors\": {\n    \"base\": [\n      \"This Unit can not be found in the current user's Units\"\n    ]\n  }\n}")
	example DocHelper.format_example(status = 422, nil, body = "{\n  \"errors\": {\n    \"department.university\": [\n      \"can't be blank\"\n    ]\n  }\n}")
	description <<-EOS
		Update a Unit. A Unit belongs to a Department. If a department_id is supplied in the params,
		the unit will become associated with an existing Department. If department_attributes are present,
		then a new Department will be created and associated with the Unit. In case both department_id, and
		department_attributes are present, the department_id takes precedence, and the new Unit is associated
		with an existing Department.
	EOS
	def update
	end

	api :DELETE, '/units/:id', 'Delete Unit'
	meta :authentication? => true
	param :id, String, 'The id of the department', required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'This User is not the owner of this resource'
	error code: 422, desc: "Invalid params"
	description <<-EOS
		Delete unit resource
	EOS
	def destroy
	end
end
