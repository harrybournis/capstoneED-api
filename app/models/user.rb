class User < ApplicationRecord

  # authentication
  #
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable

  include DeviseTokenAuth::Concerns::User
  attr_accessor :confirm_success_url, :config_name

  # validations
  #
  validates :first_name, :last_name, presence: true

  def full_name
  	"#{self.fist_name} #{self.last_name}"
  end

end
