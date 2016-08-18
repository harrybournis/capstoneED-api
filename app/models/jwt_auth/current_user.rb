class JWTAuth::CurrentUser

	def initialize (user_id)
		@id = user_id
	end

	def load_user
		@user ||= User.find(@id)
	end

end
