class User < ApplicationRecord

	# Associations
	has_many :active_tokens, dependent: :destroy

	# Includes
	include User::EmailAuthenticatable
	devise :database_authenticatable, :confirmable, :recoverable,
	       :trackable, :validatable

	# Validations
	validates_presence_of :first_name, :last_name

å
	### Instance Methods
	#
	def full_name ; "#{first_name} #{last_name}" end

	# Disallow assignment to the provider attribute
	def provider=(value)
		if self.persisted?
			self.errors.add(:provider, "can't be modified for security reasons.")
			return false
		end
		super
	end

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


protected


	# overrides the default devise method in validatable.rb to require password
	# only if user signed up via email
	def password_required?
		(!persisted? && provider == 'email') || !password.nil? || !password_confirmation.nil?
	end
end
