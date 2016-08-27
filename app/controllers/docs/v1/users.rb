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


	api :GET, '/confirmation', 'Confirm your account'
	param :confirmation_token, String, 'The confirmation token is contained as a parameter in the link that is sent to the user to confirm their account.', required: true
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
	param :email, String, "User's Email", required: true
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

	api :PATCH, '/password', "Reset user's password"
	param :reset_password_token, String, "Part of the url that brought the user to the 'reset your password page'", required: true
	param :password, String, 'New Password', required: true
	param :password_confirmation, String, 'Must equal password', required: true
	error code: 400, desc: 'The request is missing the reset_password_token param'
	error code: 422, desc: 'password_reset_token, password or password_confirmation is invalid'
	example DocHelper.format_example(status = 204)
	example DocHelper.format_example(status = 400, nil, body = "{\n  \"errors\": {\n    \"reset_password_token\": [\n      \"can't be blank\"\n    ]\n  }\n}")
	example DocHelper.format_example(status = 422, nil, body = "{\n  \"errors\": {\n    \"reset_password_token\": [\n      \"is invalid\"\n    ]\n  }\n}")
	description <<-EOS
		To successfully reset a user's password, the user's reset_password_token needs to be present in
		the params. To get that, the client must extract it from the params of the request that brought the
		user to the 'reset your password form'.
	EOS
	def reset_password
	end

	api :POST, '/password', 'Send a Reset your password Email'
	param :email, String, "User's Email", required: true
	error code: 403, desc: 'User was found, however they did not register with email/password, thus they have no password to reset.'
	error code: 422, desc: 'Email is invalid, or email failed to be sent'
	example DocHelper.format_example(status = 204, headers = "{\n  \"X-Frame-Options\": \"SAMEORIGIN\",\n  \"X-XSS-Protection\": \"1; mode=block\",\n  \"X-Content-Type-Options\": \"nosniff\"\n}")
	example DocHelper.format_example(status = 403, nil, body = "{\n  \"errors\": {\n    \"provider\": [\n      \"is test. Did not authenticate with email/password.\"\n    ]\n  }\n}")
	example DocHelper.format_example(status = 422, nil, body = "{\n  \"errors\": {\n    \"email\": [\n      \"is invalid\"\n    ]\n  }\n}")
	description <<-EOS
		Send a reset password email to the given email. The email will only be sent if it matches a user
		in the system. The sent email will contain a url for the user to visit, with a reset_password
		token.
	EOS
	def send_reset_password_email
	end
end
