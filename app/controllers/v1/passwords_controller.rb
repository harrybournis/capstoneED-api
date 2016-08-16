class User::PasswordsController < Devise::PasswordsController
  # prepend_before_action :require_no_authentication
  # # Render the #edit only if coming from a reset password email link
  skip_before_action :authenticate_user_jwt, except: [:new, :edit, :update]
  append_before_action :assert_reset_token_passed, only: :update


  # GET /resource/password/new
  def new
    render json: :none, status: :not_found
  end

  # POST /resource/password
  def create
    # self.resource = resource_class.send_reset_password_instructions(resource_params)
    #   yield resource if block_given?

    #   if successfully_sent?(resource)
    #     respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    #   else
    #     respond_with(resource)
    # end
    #
    # Create password reset token and send email instructions
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    # the update action will check for the reset token
    render json: :none, status: :not_found
  end

  # PUT /resource/password
  def update
      # self.resource = resource_class.reset_password_by_token(resource_params)
      # yield resource if block_given?

      # if resource.errors.empty?
      # resource.unlock_access! if unlockable?(resource)
      # if Devise.sign_in_after_reset_password
      #   flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      #   set_flash_message!(:notice, flash_message)
      #   sign_in(resource_name, resource)
      # else
      #   set_flash_message!(:notice, :updated_not_active)
      # end
      # respond_with resource, location: after_resetting_password_path_for(resource)
      # else
      # set_minimum_password_length
      # respond_with resource
      # end
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
