API root: api.localhost:3000/

| Method | Endpoint | Usage  | Returns |
|:-:|:-:|:-:|:-:|---|
| GET  | /v1/users  |  Get all users  | Users[]  |   
| POST    | /auth   | Email registration. Requires email, password, and password_confirmation params. | user |
| DELETE | /auth | Account deletion. This route will destroy users identified by their uid and auth_token headers. |
| PUT | /auth | Account updates. This route will update an existing user's account settings. The default accepted params are password and password_confirmation, but this can be customized using the devise_parameter_sanitizer system. If config.check_current_password_before_update is set to :attributes the current_password param is checked before any update, if it is set to :password the current_password param is checked only if the request updates user password. |
| POST | auth/sign_in | Email authentication. Requires email and password as params. This route will return a JSON representation of the User model on successful login along with the access-token and client in the header of the response. |
| DELETE | auth/sign_out | Use this route to end the user's current session. This route will invalidate the user's authentication token. You must pass in uid, client, and access-token in the request headers. |