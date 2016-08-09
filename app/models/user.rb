class User < ApplicationRecord

	has_one :revoked_token

	validates_presence_of :first_name, :last_name, :user_name, :email, :uid
	validates_uniqueness_of :user_name, :email, :uid

	def full_name
		"#{first_name} #{last_name}"
	end

	# in case a token has been compromized, running this will create
	# a revoked_token entry with with the current time + the expiration time
	# for a refresh token.
	def revoke_all_tokens
		token_expiration = DateTime.now + JWTAuthenticator.refresh_exp
		token =
				if self.revoked_token
					self.revoked_token.exp = token_expiration
					self.revoked_token
				else
					 RevokedToken.new(jti: self.uid, exp: token_expiration, user: self)
				end

		token.save
	end
end
