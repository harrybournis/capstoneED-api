class Documentation::V1::AuthenticationsControllerDoc < ApplicationController

	include Documentation::Helpers::DocHelper
	DocHelper = Documentation::Helpers::DocHelper

	resource_description do
	  short 'Sign In, Sign Out, register with OAuth'
	  name 'Authentications'
	  api_base_url '/v1/users'
	  api_version 'v1'
	  description 'The User model handles authentication.'
	end


	api :POST, '/register', 'Register a new user using email and password as authentication'
	param :email, String,									'A unique email', 								required: true
	param :password, String,							'Minimum 8 characters', 					required: true
	param :password_confirmation, String, 'Must equal the password param', 	required: true
	param :first_name, String,						"User's first name", 							required: true
	param :last_name, String,							"User's last name", 							required: true
	error code: 400, desc: 'Params missing. Did not receive either email, password or password_confirmation in params. See errors in response body.'
	error code: 422, desc: "Failed to save User. Params are invalid. See errors in response body."
	example DocHelper.format_example(status = 200)
	example DocHelper.format_example(status = 422, nil, body = "{\n  \"errors\": {\n    \"email\": [\n      \"is invalid\"\n    ],\n    \"password\": [\n      \"is too short (minimum is 8 characters)\"\n    ],\n    \"first_name\": [\n      \"can't be blank\"\n    ]\n  }\n}")
	description <<-EOS
		Register a new User resource that is authenticatable with email and password.
		For registering a user with OAuth please refer to <link>.
	EOS
	def register
	end

	api :PATCH, '/:id', 'Update user resource'
	param :id, String,	'The users ID in the database. Used to find the user.', required: true
	param :email, String,	'A unique email'
	param :current_password, String, "Only required if password and password_confirmation are sent in the params"
	param :password, String, 'Minimum 8 characters. Requires current_password to be present in the params'
	param :password_confirmation, String, 'Must equal the password param. Requires current_password to be present in the params'
	param :first_name, String, "User's first name"
	param :last_name, String, "User's last name"
	error code: 401, desc: 'User Authentication failed'
	error code: 403, desc: 'The User to be updated is not the authenticated user. One can only update themselves.'
	error code: 422, desc: "Failed to save User. Params are invalid. See errors in response body."
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"user\": {\n    \"id\": 30876,\n    \"first_name\": \"different\",\n    \"last_name\": \"Metz\",\n    \"email\": \"quentin.senger@gmail.com\"\n  }\n}")
	example DocHelper.format_example(status = 422, nil, body = "{\n  \"errors\": {\n    \"password_confirmation\": [\n      \"doesn't match Password\"\n    ]\n  }\n}")
	description <<-EOS
		Update an existing user. If the request aims to update the user's password,
		along with <b>password</b> and <b>password_confirmation</b>, the user's current password must
		be provided as <b>current_password</b> in the params."
	EOS
	def update
	end

	api :DELETE, '/:id', 'Delete a user resource'
	param :id, String, 'The users ID in the database. Used to find the user.', required: true
	param :current_password, String, "A user has to enter their password to delete their account."
	error code: 401, desc: 'User Authentication failed'
	error code: 403, desc: 'The User to be deleted is not the authenticated user. One can only delete themselves.'
	error code: 422, desc: 'Failed to delete user. Either the id or the current_password are invalid.'
	example DocHelper.format_example(status = 204)
	example DocHelper.format_example(status = 403, nil, body = "{\n  \"errors\": {\n    \"user\": [\n      \"User with id 32113 is not authorized to access this resourse.\"\n    ]\n  }\n}")
	example DocHelper.format_example(status = 422, nil, body = "{\n  \"errors\": {\n    \"current_password\": [\n      \"is invalid\"\n    ]\n  }\n}")
	description <<-EOS
		Delete a user. the user's id must be provided as part of the url, and their valid password must
		be included in the body as <b>current_password </b>
	EOS
	def destroy
	end
end
