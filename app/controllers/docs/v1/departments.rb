class Docs::V1::Departments < ApplicationController

	include Docs::Helpers::DocHelper
	DocHelper = Docs::Helpers::DocHelper

	resource_description do
	  short 'A Department has many Units'
	  name 'Departments'
	  api_base_url '/v1'
	  api_version 'v1'
	  meta attributes: { name: 'String', university: 'String' }
	  description <<-EOS
			A Department has a name and a university attribute. Each name is unique(?) for each university.
			A Unit belongs to a Department.
	  EOS
	end


	# api :POST, '/departments', 'Create a new Department resource'
	# meta :authentication? => true
	# param :university, 		String, "The University that the Department belongs to", 		required: true
	# param :name, 	String, "The name of the department, e.g. Computer Science",	required: true
	# error code: 401, desc: 'Authentication failed'
	# error code: 403, desc: 'Current User is not a lecturer'
	# error code: 422, desc: "University or name are missing from the params"
	# example DocHelper.format_example(status = 200, headers = "{\n  \"X-Frame-Options\": \"SAMEORIGIN\",\n  \"X-XSS-Protection\": \"1; mode=block\",\n  \"X-Content-Type-Options\": \"nosniff\",\n  \"XSRF-TOKEN\": \"T8s44Z44kQR0BbidKGhlvSC7mQoDoTf4lKWnuT1Z5LA=\",\n  \"Content-Type\": \"application/json; charset=utf-8\",\n  \"Set-Cookie\": \"access-token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0NzE5OTU1MDIsImlkIjozMzYzOSwidHlwZSI6bnVsbCwiaXNzIjoiIiwiZGV2aWNlIjoiTGN2RjZDQnZTVzJ6bGtGbnp4SmJVTmpaWTl5SzJhazlmMnl1b3NEWkZFdz0iLCJjc3JmX3Rva2VuIjoiVDhzNDRaNDRrUVIwQmJpZEtHaGx2U0M3bVFvRG9UZjRsS1dudVQxWjVMQT0ifQ.YbqfKaDyjZXXPXkuzhvhfcLQhcRz-OxkKveg7AeHMLg; path=/; expires=Tue, 23 Aug 2016 23:38:22 -0000; HttpOnly; SameSite=Strict\\nrefresh-token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0NzI1OTk3MDIsImlzcyI6IiIsImRldmljZSI6IkxjdkY2Q0J2U1cyemxrRm56eEpiVU5qWlk5eUsyYWs5ZjJ5dW9zRFpGRXc9In0.BrkCthYzKmwJn2JMYhsEeOqr8-o2-5W_L97lnOJFIl4; path=/v1/refresh; expires=Tue, 30 Aug 2016 23:28:22 -0000; HttpOnly; SameSite=Strict\"\n}", body = "{\n  \"department\": {\n    \"id\": 113,\n    \"university\": \"Harvard\",\n    \"name\": \"Computer Science\"\n  }\n}")
	# example DocHelper.format_example(status = 403, nil, body = "{\n  \"errors\": {\n    \"type\": [\n      \"must be Lecturer\"\n    ]\n  }\n}")
	# description <<-EOS
	# 	Create a new Department.
	# EOS
	# def create
	# end

	api :PATCH, '/departments/:id', 'Update Department'
	meta :authentication? => true
	param :id, String, 'The id of the department', required: true
	param :university, 		String, "The University that the Department belongs to"
	param :name, 	String, "The name of the department, e.g. Computer Science"
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 422, desc: "University or name are missing from the params"
	description <<-EOS
		Update a Department resource.
	EOS
	def update
	end

	api :DELETE, '/departments/:id', 'Delete Department'
	meta :authentication? => true
	param :id, String, 'The id of the department', required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 422, desc: "University or name are missing from the params"
	description <<-EOS
		Delete department resource
	EOS
	def destroy
	end
end
