class User < ApplicationRecord

	has_one :revoked_token

	validates_presence_of :first_name, :last_name, :user_name, :email, :uid
	validates_uniqueness_of :user_name, :email, :uid

	def full_name
		"#{first_name} #{last_name}"
	end
end
