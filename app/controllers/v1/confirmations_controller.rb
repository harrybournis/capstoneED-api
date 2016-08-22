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
      render json: '', status: :ok
    else
      render json: '', status: :unprocessable_entity
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  # Accept confirmation. must have confirmation token in params
  def show
    @user = User.confirm_by_token(params[:confirmation_token])

    if @user.errors.empty?
      redirect_to "capstoned.com/account_confirmed"           # REPLACE WITH ACTUAL PAGE
    else
      redirect_to "capstoned.com/account_confirmation_failed" # REPLACE WITH ACTUAL PAGE
    end
  end

  protected

  def confirmation_params
    params.permit(:email)
  end

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end

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
