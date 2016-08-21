API root: localhost:3000/v1

# Authentication Routes #

Method 	| Endpoint | Authentication | Usage  				   |  ✓  | ✖ 
--------|----------|----------------|--------------------------|-----|-----------------
GET     |/me       | access-token	| Returns the current_user | "user": { "id": "", ... } | 401 |
POST    |/register | -           	| Creates new user. Expects: `email`, `password`, `password_confirmation` | 201 | "email": ["is invalid"]

# Student Routes #