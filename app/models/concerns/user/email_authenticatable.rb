# User mixin. Provides functionality for authenticating by email.
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

    # Valudates sign in params. Checks if email exists in teh database,
    # and whether the password in correct.
    # Returns error if wrong email, password, remember_me value or if
    # user has not yet confirmed their account.
    #
    # @param params The paras that will be used to authenticate.
    #   Must include email, password, remember me.
		def validate_for_sign_in (params)
			user = User.find_by_email(params[:email])

			user ||= User.new

			if params[:remember_me].present? && !['0', '1'].include?(params[:remember_me])
				user.errors[:base] << "remember_me must be either '0' or '1'. Received value: #{params[:remember_me]}"
			end
			unless user && user.valid_password?(params[:password])
				user.errors[:base] << 'Invalid Login Credentials'
			end
			user.errors.add(:email, 'is unconfirmed') if user.persisted? && !user.confirmed?
			user
		end
	end

end
