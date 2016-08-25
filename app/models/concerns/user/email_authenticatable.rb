module User::EmailAuthenticatable

	extend ActiveSupport::Concern

	# Called on a new user object before save. It generates a unique uid and
	# encrypts the password using devise's bcrypt method.
	#
	# returns self
	def process_new_record
		self.provider = 'email'
		password = self.password # encrypts password
		return self
	end

	module ClassMethods

		def validate_for_sign_in (params)
			user = User.find_by_email(params[:email])

			user ||= User.new
			user.errors.add(:email, 'is invalid') 		unless user
			user.errors.add(:password, 'is invalid') 	unless user.valid_password?(params[:password])
			user.errors.add(:email, 'is unconfirmed') if !user.confirmed?
			user
		end
	end

end
