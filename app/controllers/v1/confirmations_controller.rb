class V1::ConfirmationsController < Devise::ConfirmationsController

  skip_before_action  :authenticate_user_jwt


  # GET /resource/confirmation/new
  def new
    render json: '', status: :not_found
  end

  # POST /resource/confirmation
  # resend confirmation. requires an email in params
  def create
    @unconfirmed_user = User.send_confirmation_instructions({ email: confirmation_params[:email] })

    if successfully_sent?(@unconfirmed_user)
      render json: '', status: :no_content
    else
      render json: format_errors(@unconfirmed_user.errors), status: :unprocessable_entity
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  # Accept confirmation. must have confirmation token in params
  def show
    @user = User.confirm_by_token(params[:confirmation_token])

    if @user.errors.empty?
      api_confirmation_success_url # change @ url_helper.rb
    else
      api_confirmation_failure_url # change @ url_helper.rb
    end
  end

  protected

  def confirmation_params
    params.permit(:email)
  end

  # Helper for use after calling send_*_instructions methods on a resource.
  # If we are in paranoid mode, we always act as if the resource was valid
  # and instructions were sent.
  #
  # OVERRIDE: Removed updating the flash
  def successfully_sent?(resource)
    notice = if Devise.paranoid
      resource.errors.clear
      :send_paranoid_instructions
    elsif resource.errors.empty?
      :send_instructions
    end

    return true if notice
  end

end
