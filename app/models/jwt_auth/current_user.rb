class JWTAuth::CurrentUser

	def initialize (user_uid)
		@uid = user_uid
	end

	def load_user
		@user ||= User.find_by_uid(@uid)
	end

end
