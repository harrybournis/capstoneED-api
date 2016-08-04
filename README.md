API root: api.localhost:3000/

| Method | Endpoint | Usage  | Returns |
|:-:|:-:|:-:|:-:|---|
| GET  | /v1/users  |  Get all users  | Users[]  |   
| POST    | /auth   | Email registration. Requires email, password, and password_confirmation params. | user |
| DELETE | /auth | Account deletion. This route will destroy users identified by their uid and auth_token headers. |
| PUT | /auth | Account updates. This route will update an existing user's account settings. The default accepted params are password and password_confirmation, but this can be customized using the devise_parameter_sanitizer system. If config.check_current_password_before_update is set to :attributes the current_password param is checked before any update, if it is set to :password the current_password param is checked only if the request updates user password. |
| POST | auth/sign_in | Email authentication. Requires email and password as params. This route will return a JSON representation of the User model on successful login along with the access-token and client in the header of the response. |
| DELETE | auth/sign_out | Use this route to end the user's current session. This route will invalidate the user's authentication token. You must pass in uid, client, and access-token in the request headers. |
| GET | auth/:provider | Set this route as the destination for client authentication. Ideally this will happen in an external window or popup. |
| GET/POST | auth/:provider/callback | Destination for the oauth2 provider's callback uri. postMessage events containing the authenticated user's data will be sent back to the main client window from this page. |
| GET | auth/validate_token | Use this route to validate tokens on return visits to the client. Requires uid, client, and access-token as params. These values should correspond to the columns in your `User` table of the same names. |
| POST | auth/password | Use this route to send a password reset confirmation email to users that registered by email. Accepts email and redirect_url as params. The user matching the `email` param will be sent instructions on how to reset their password. redirect_url is the url to which the user will be redirected after visiting the link contained in the email. |
| PUT | auth/password | Use this route to change users' passwords. Requires password and password_confirmation as params. This route is only valid for users that registered by email (OAuth2 users will receive an error). It also checks current_password if config.check_current_password_before_update is not set false (disabled by default). |
| GET | auth/password/edit | Verify user by password reset token. This route is the destination URL for password reset confirmation. This route must contain reset_password_token and redirect_url params. These values will be set automatically by the confirmation email that is generated by the password reset request. |