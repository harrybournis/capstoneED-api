class ActiveToken < ApplicationRecord
	# Attributes
	# exp 		:datetime
	# user_id	:integer
	# device	:string

	belongs_to :user

	validates_presence_of :user, :exp, :device
	validates_uniqueness_of :id
	validates_uniqueness_of :device
end
