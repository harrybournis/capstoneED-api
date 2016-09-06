class Docs::V1::Authentication < ApplicationController

	include Docs::Helpers::DocHelper
	DocHelper = Docs::Helpers::DocHelper

	resource_description do
	  short 'Sign In, Sign Out, register with OAuth'
	  name 'Authentications'
	  api_base_url '/v1'
	  api_version 'v1'
	  description <<-EOS
	  	Authentication is implemented using <b> JWT (JSON Web Tokens) </b>.
	  	<p>
	  	After successful authentication, a user is issued two JWT tokens which are stored in secure,
	  	http-only cookies. Both tokens have an expiration date. The first token, the <b> access-token </b>
	  	is used to authenticate the user on following requests. The second token, the <b> refresh-token </b>
	  	is only sent to the /refresh path and is used to issue the user a new access-token.
	  	<p>
	  	To prevent CSRF Attacks, the access-token contains a csrf-token value, which is equal to the
	  	XSRF-TOKEN header that the response contains upon successful authentication. The client must
	  	send the token contained in the params on each request that requires authentication, is a header
	  	called X-XSRF-TOKEN. The X-XSRF-TOKEN header and the csrf-token value in the access-token are
	  	compared by the server.
	  	<p>
	  	<expand..........>
	  EOS
	end


	api :POST, '/sign_in', 'Sign In using Email and Password'
	param :email, 		String, "User's Email", 		required: true
	param :password, 	String, "User's Password",	required: true
	error code: 401, desc: 'Missing email/password, wrong email/password, or unconfirmed account. see errors in response body.'
	example DocHelper.format_example(status = 200, headers = "{\n  \"X-Frame-Options\": \"SAMEORIGIN\",\n  \"X-XSS-Protection\": \"1; mode=block\",\n  \"X-Content-Type-Options\": \"nosniff\",\n  \"XSRF-TOKEN\": \"T8s44Z44kQR0BbidKGhlvSC7mQoDoTf4lKWnuT1Z5LA=\",\n  \"Content-Type\": \"application/json; charset=utf-8\",\n  \"Set-Cookie\": \"access-token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0NzE5OTU1MDIsImlkIjozMzYzOSwidHlwZSI6bnVsbCwiaXNzIjoiIiwiZGV2aWNlIjoiTGN2RjZDQnZTVzJ6bGtGbnp4SmJVTmpaWTl5SzJhazlmMnl1b3NEWkZFdz0iLCJjc3JmX3Rva2VuIjoiVDhzNDRaNDRrUVIwQmJpZEtHaGx2U0M3bVFvRG9UZjRsS1dudVQxWjVMQT0ifQ.YbqfKaDyjZXXPXkuzhvhfcLQhcRz-OxkKveg7AeHMLg; path=/; expires=Tue, 23 Aug 2016 23:38:22 -0000; HttpOnly; SameSite=Strict\\nrefresh-token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0NzI1OTk3MDIsImlzcyI6IiIsImRldmljZSI6IkxjdkY2Q0J2U1cyemxrRm56eEpiVU5qWlk5eUsyYWs5ZjJ5dW9zRFpGRXc9In0.BrkCthYzKmwJn2JMYhsEeOqr8-o2-5W_L97lnOJFIl4; path=/v1/refresh; expires=Tue, 30 Aug 2016 23:28:22 -0000; HttpOnly; SameSite=Strict\"\n}", body = "{\n  \"user\": {\n    \"id\": 33639,\n    \"first_name\": \"Mireille\",\n    \"last_name\": \"Buckridge\",\n    \"email\": \"estelle@hotmail.com\"\n  }\n}")
	example DocHelper.format_example(status = 401, nil, body = "{\n  \"errors\": {\n    \"base\": [\n      \"Invalid Login Credentials\"\n    ]\n  }\n}")
	example DocHelper.format_example(status = 401, nil, body = "{\n  \"errors\": {\n    \"email\": [\n      \"is unconfirmed\"\n    ]\n  }\n}")
	description <<-EOS
		Sign In using Email and Password. The user must have confirmed their account through the
		confirmation email sent after /register. On successful authentication, the user is returned. The
		XSRF-TOKEN header is added to the response, which should be saved on the client, to be added in
		subsequent requests under the header X-XSRF-TOKEN. The response also sets two cookies, one with the
		access-token, and one with the refresh-token, which are secure and http-only, thus they are not
		accessible via javascript, and require no further action for the client in order to use them.
		The access-token cookie will automatically be sent to all subsequent requests, while the
		refresh-token cookie will only be sent to the /refresh path.
	EOS
	def sign_in_email
	end

	api :DELETE, '/sign_out', 'Sign Out'
	meta :authentication? => true
	error code: 401, desc: 'User Authentication Failed'
	example DocHelper.format_example(status = 204, headers = "{\n  \"X-Frame-Options\": \"SAMEORIGIN\",\n  \"X-XSS-Protection\": \"1; mode=block\",\n  \"X-Content-Type-Options\": \"nosniff\",\n  \"Set-Cookie\": \"access-token=; domain=; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000\\nrefresh-token=; domain=; path=/v1/refresh; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000\"\n}")
	example DocHelper.format_example(status = 401)
	description <<-EOS
		Sign out of the application. One has to be authenticated in order to sign out, meaning that the
		requrest has to have an access-token cookie, and an X-XSRF-TOKEN header. On successful authentication,
		the user's refresh-token is deleted from the database, as well as the access-token and refresh-token
		cookies.
	EOS
	def sign_out
	end

	api :POST, '/refresh', 'Refresh the access-token using the refresh-token'
	error code: 401, desc: 'User Authentication failed'
	example DocHelper.format_example(status = 204, headers = "{\n  \"X-Frame-Options\": \"SAMEORIGIN\",\n  \"X-XSS-Protection\": \"1; mode=block\",\n  \"X-Content-Type-Options\": \"nosniff\",\n  \"XSRF-TOKEN\": \"CwZiQ5KHhiGNQ7uDTLzSIXToF/fKbkOHTVKbSiMP6as=\",\n  \"Set-Cookie\": \"access-token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0NzE5OTY3OTYsImlkIjozNDAwNSwidHlwZSI6bnVsbCwiaXNzIjoiIiwiZGV2aWNlIjoiTTczODFKU3o5YzhSLzJicFhMbit0Y1Jrclp6ajFLQ2ZuMUNuYXk4cnhnMD0iLCJjc3JmX3Rva2VuIjoiQ3daaVE1S0hoaUdOUTd1RFRMelNJWFRvRi9mS2JrT0hUVktiU2lNUDZhcz0ifQ.uiIvs1KxjD_M7GpDhEcITaLwH2RvXD0oH8h_Vkcur9E; path=/; expires=Tue, 23 Aug 2016 23:59:56 -0000; HttpOnly; SameSite=Strict\\nrefresh-token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0NzI2MDA5OTYsImlzcyI6IiIsImRldmljZSI6Ik03MzgxSlN6OWM4Ui8yYnBYTG4rdGNSa3JaemoxS0NmbjFDbmF5OHJ4ZzA9In0.QjyzPbjxLsjTwXOoSzgGeF-VcSZ08pwnR37FOQ-jJ-A; path=/v1/refresh; expires=Tue, 30 Aug 2016 23:49:56 -0000; HttpOnly; SameSite=Strict\"\n}")
	example DocHelper.format_example(status = 401)
	description <<-EOS
		Refresh the access-token of the user. Requires a refresh-token stored in a cookie. On successful
		validation of the refresh-token, the response sets two new access-token and refresh-token cookies,
		and contains a new XSRF-TOKEN header, to be saved by the client.
	EOS
	def refresh
	end

	api :GET, '/me', 'Returns the current_user'
	meta :authentication? => true
	error code: 401, desc: 'User Authentication failed. Either the X-XSRF-TOKEN is missing from the headers, or the access-token is missing, invalid or expired'
	example DocHelper.format_example(status = 200)
	example DocHelper.format_example(status = 401)
	description <<-EOS
		Authenticate with the server after exiting the application. Returns the current_user in the
		response body. Due to the short expiration time of the access-token, requests to this endpoint
		will most likely be successful for a short period of time. If the request is not successful,
		the application should send a request to the <a href='#'> /refresh </a> route, in order to receive
		a new access-token.
	EOS
	def me
	end
end
