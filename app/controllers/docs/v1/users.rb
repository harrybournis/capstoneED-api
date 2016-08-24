class Docs::V1::Users < ApplicationController

	include Docs::Helpers::DocHelper
	DocHelper = Docs::Helpers::DocHelper

	resource_description do
	  short 'Superclass of Student and Lecturer'
	  name 'User'
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
	meta :authentication? => true
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
	meta :authentication? => true
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

		api :GET, '/confirmation', 'Confirm your account'
	param :confirmation_token, String, 'The confirmation token is contained as a parameter in the link that is sent to the user to confirm their account.'
	example DocHelper.format_example(status = 302, headers = "{\n  \"X-Frame-Options\": \"SAMEORIGIN\",\n  \"X-XSS-Protection\": \"1; mode=block\",\n  \"X-Content-Type-Options\": \"nosniff\",\n  \"Location\": \"http://test.hostcapstoned.com/account_confirmation_success\",\n  \"Content-Type\": \"text/html; charset=utf-8\"\n}", body = "{\n<html><body>You are being <a href=\"http://test.hostcapstoned.com/account_confirmation_success\">redirected</a>.</body></html> \n}")
	example DocHelper.format_example(status = 302, headers = "{\n  \"X-Frame-Options\": \"SAMEORIGIN\",\n  \"X-XSS-Protection\": \"1; mode=block\",\n  \"X-Content-Type-Options\": \"nosniff\",\n  \"Location\": \"http://test.hostcapstoned.com/account_confirmation_failure\",\n  \"Content-Type\": \"text/html; charset=utf-8\"\n}", body = "{\n<html><body>You are being <a href=\"http://test.hostcapstoned.com/account_confirmation_failure\">redirected</a>.</body></html> \n}")
	description <<-EOS
		Accept Confirmation. The link contained in the email sent to the user points to this route.
		It redirects to a 'success' or 'failure' page to inform the user. Evaluates the confirmation token
		contained within the params and confirms or rejects the user.
		If this fails, assure that the link sent to the user contains the confirmation token in the url,
		and offer the user the option to resend the confirmation email through the POST /confirmation endpoint.
	EOS
	def confirm
	end

	api :POST, '/confirmation', 'Resend confirmation email'
	param :email, String, "User's Email"
	error code: 401, desc: 'User Authentication failed'
	example DocHelper.format_example(status = 204)
	example DocHelper.format_example(status = 422, nil, body = "{\n  \"errors\": {\n    \"email\": [\n      \"was already confirmed, please try signing in\"\n    ]\n  }\n}")
	example DocHelper.format_example(status = 422, nil, body = "{\n  \"errors\": {\n    \"email\": [\n      \"can't be blank\"\n    ]\n  }\n}")
	description <<-EOS
		Resends a confirmation email to the email provided in the params. The email must be a valid email
		in the system.
	EOS
	def resend
	end
end
