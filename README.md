API root: localhost:3000/v1

# Authentication Routes #

| Method | Endpoint | Authentication | Usage  | Success | Fail|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|---|
|GET     |/me       | access-token| Returns the current_user | 200 | 401 |
|POST    |/register | -           | Creates new user. Expects params: email, password, password_confirmation | 201 | 422

# Student Routes #