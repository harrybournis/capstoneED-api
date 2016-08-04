class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable

  include DeviseTokenAuth::Concerns::User

  attr_accessor :confirm_success_url, :config_name

  def full_name
  	"#{self.fist_name} #{self.last_name}"
  end
end
