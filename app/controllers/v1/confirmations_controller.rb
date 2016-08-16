class User::ConfirmationsController < Devise::ConfirmationsController
  skip_before_action :authenticate_user_jwt, only: [:new, :edit]


  # GET /resource/confirmation/new
  def new
    render json: :none, status: :not_found
  end

  # POST /resource/confirmation
  def create
    # self.resource = resource_class.send_confirmation_instructions(resource_params)
    # yield resource if block_given?

    # if successfully_sent?(resource)
    #   respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
    # else
    #   respond_with(resource)
    # end
    #
    # Send confirmation instructions
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    # self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    # yield resource if block_given?

    # if resource.errors.empty?
    #   set_flash_message!(:notice, :confirmed)
    #   respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    # else
    #   respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    # end
    #
    # Accept confirmation. must have confirmation token in params
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
