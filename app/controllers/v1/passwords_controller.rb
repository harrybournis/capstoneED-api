## Passwords Controller
class V1::PasswordsController < Devise::PasswordsController
  # Render the #edit only if coming from a reset password email link
  skip_before_action :authenticate_user_jwt

  include ApiHelper

  # GET /resource/password/new
  def new
    render json: '', status: :not_found
  end

  # POST /resource/password
  # Create password reset token and send email instructions.
  # requires email in params
  def create
    if @user = User.find_by(email: password_params[:email])
      if @user.provider != 'email'
        @user.errors.add(:provider, "is #{@user.provider}. Did not authenticate with email/password.")
        render json: format_errors(@user.errors), status: :forbidden
        return
      end

      @user = User.send_reset_password_instructions(password_params)

      if successfully_sent?(@user)
        render json: '', status: :no_content
      else
        render json: format_errors(@user.errors), status: :unprocessable_entity
      end
    else
      render json: format_errors({ email: ['is invalid'] }),
             status: :unprocessable_entity
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    # the update action will check for the reset token
    render json: '', status: :not_found
  end

  # PUT /resource/password
  #
  # requires reset_password_token, password, password_confirmation in params
  def update
    if params[:reset_password_token].blank?
      render json: format_errors(reset_password_token: ["can't be blank"]),
             status: :bad_request
      return
    end

    @user = User.reset_password_by_token(password_params)

    if @user.errors.empty?
      render json: '', status: :no_content
    else
      render json: format_errors(@user.errors), status: :unprocessable_entity
    end
  end

  protected

  def password_params
    params.permit(:email, :reset_password_token,
                  :password, :password_confirmation)
  end

  # Helper for use after calling send_*_instructions methods on a resource.
  # If we are in paranoid mode, we always act as if the resource was valid
  # and instructions were sent.
  #
  # OVERRIDE: Removed updating the flash
  def successfully_sent?(resource)
    notice =  if Devise.paranoid
                resource.errors.clear
                :send_paranoid_instructions
              elsif resource.errors.empty?
                :send_instructions
              end
    return true if notice
  end
end
