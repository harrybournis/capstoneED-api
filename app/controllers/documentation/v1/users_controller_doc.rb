class Documentation::V1::UsersControllerDoc < ApplicationController

	resource_description do
	  short 'Superclass of Student and Lecturer'
	  name 'User'
	  api_base_url '/v1/users'
	  api_version 'v1'
	  description 'User is authenticatable. '
	end

	api :POST, '/register', 'Register a new user using email and password as authentication'
	description 'Used to register a new User resource that is authenticatable with email and password. For registering a user with OAuth please refer to <link>.'
	param :email, String,									'A unique email', 								required: true
	param :password, String,							'Minimum 8 characters', 					required: true
	param :password_confirmation, String, 'Must equal the password param', 	required: true
	param :first_name, String,						"User's first name", 							required: true
	param :last_name, String,							"User's last name", 							required: true
	error code: 400, desc: 'Params missing. Did not receive either email, password or password_confirmation in params. See errors in response body.'
	error code: 422, desc: "Failed to save User. Params are invalid. See errors in response body."
	example " 'email': 'email@email.com', 'password': '12345678', 'password_confirmation': '12345678', 'first_name': 'Bob', 'last_name': 'Lastnamovic' "
	#####
	def register
	end
end
