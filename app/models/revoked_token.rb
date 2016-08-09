class RevokedToken < ApplicationRecord

	belongs_to :user

	validates_presence_of :user, :jti, :exp
	validates_uniqueness_of :jti, :user
	validate :jti_equal_to_users_uid, if: :user


private

	def jti_equal_to_users_uid
		errors.add(:jti, "jti must match the associated user's uid") unless jti == user.uid
	end
end
