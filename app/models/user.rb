class User < ApplicationRecord

	has_many :active_tokens

	validates_presence_of :first_name, :last_name, :user_name, :email, :uid
	validates_uniqueness_of :user_name, :email, :uid

	def full_name
		"#{first_name} #{last_name}"
	end

	# in case a token has been compromized, running this will create
	# a revoked_token entry with with the current time + the expiration time
	# for a refresh token.
	def revoke_all_tokens
		token_expiration = DateTime.now + JWTAuth::JWTAuthenticator.refresh_exp
		active_tokens = self.active_tokens

		return if active_tokens.blank?

		ActiveToken.transaction do
			active_tokens.each { |token| token.update(exp: token_expiration) }
		end
	end
end
