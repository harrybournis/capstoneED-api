## The currently active JWT token for a user and a device.
#  Used to revoke tokens.
class ActiveToken < ApplicationRecord
  # Attributes
  # exp 		:datetime
  # user_id	:integer
  # device	:string

  # Associations
  belongs_to :user

  # Validations
  validates_presence_of :user, :exp, :device
  validates_uniqueness_of :id, :device
end
