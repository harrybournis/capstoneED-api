API root: localhost:3000/v1

# Authentication Routes #

| Method | Endpoint | Authentication | Usage  | ✓ | ✖|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|---|
|GET     |/me       | access-token| Returns the current_user | 200 | 401 |
|POST    |/register | -           | Creates new user. Expects: `email`, `password`, `password_confirmation` |- | {"email": ["is invalid"]}

# Student Routes #