## The superclass for Lecturer and Student
class User < ApplicationRecord
  include User::EmailAuthenticatable
  devise :database_authenticatable, :confirmable, :recoverable,
         :trackable, :validatable

  # Associations
  has_many :active_tokens, dependent: :destroy
  has_many :project_evaluations

  # Validations
  validates_presence_of :first_name, :last_name
  validates_presence_of :password_confirmation, if: :password_required?
  validates_uniqueness_of :id
  validates_uniqueness_of :email, case_sensitive: false
  validates_confirmation_of :password

  # Class Constants
  USER_TYPES = %w(Student Lecturer).freeze

  # Instance Methods

  def full_name
    "#{first_name} #{last_name}"
  end

  # !! PLACEHOLDER IMAGE
  # def avatar_url
  #   'http://i.pravatar.cc/100'
  # end

  def lecturer?
    type == 'Lecturer'
  end

  def student?
    type == 'Student'
  end

  # Override provider setter to not allow editing of the provider after creation
  def provider=(value)
    if persisted?
      errors.add(:provider, "can't be modified for security reasons.")
      return false
    end
    super
  end

  # in case a token has been compromized, running this will update all
  # ActiveTokens for the user with a new expiration date starting now,
  # effectively invalidating all previous refresh tokens.
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
    !persisted? && provider == 'email' ||
      !password.nil? ||
      !password_confirmation.nil?
  end
end
