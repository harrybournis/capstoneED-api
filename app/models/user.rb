class User < ApplicationRecord

	has_many :active_tokens

	devise :database_authenticatable, :confirmable, :recoverable,
	       :trackable, :validatable

	validates_presence_of :first_name, :last_name, :user_name, :uid
	validates_uniqueness_of :user_name,  :uid

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

protected
	# overrides the default devise method in validatable.rb to require password
	# only if user signed up via email
	def password_required?
		provider == 'email' || !password.nil? || !password_confirmation.nil?
	end
end
