class User < ApplicationRecord

	has_many :active_tokens, dependent: :destroy

	devise :database_authenticatable, :confirmable, :recoverable,
	       :trackable, :validatable

	validates_presence_of :first_name, :last_name, :uid
	validates_uniqueness_of :uid


# ***> Instance methods
#
	def full_name ; "#{first_name} #{last_name}" end

	# in case a token has been compromized, running this will update all ActiveTokens
	# for the user with a new expiration date starting now, effectively invalidating
	# all previous refresh tokens.
	def revoke_all_tokens
		token_expiration = DateTime.now + JWTAuth::JWTAuthenticator.refresh_exp
		active_tokens = self.active_tokens

		return if active_tokens.blank?

		ActiveToken.transaction do
			active_tokens.each { |token| token.update(exp: token_expiration) }
		end
	end

	# Called on a new user object before save. It generates a unique uid and
	# encrypts the password using devise's bcrypt method.
	#
	# returns self
	def process_new_record
		self.uid = generate_uid
		self.provider = 'email'
		password = self.password
		return self
	end


# ***> Class Methods
#
	def self.valid_sign_in? (params)
		user = User.find_by_email(params[:email])
		user && user.valid_password?(params[:password]) ? user : nil
	end


protected

	# overrides the default devise method in validatable.rb to require password
	# only if user signed up via email
	def password_required?
		(!persisted? && provider == 'email') || !password.nil? || !password_confirmation.nil?
	end

private

	def generate_uid
		uid = nil
		loop do
			uid = SecureRandom.base64(32)
			break unless User.find_by_uid(uid)
		end
		uid
	end
end
