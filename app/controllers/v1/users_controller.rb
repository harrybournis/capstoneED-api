class V1::UsersController < ApplicationController

	skip_before_action :authenticate_user_jwt, only: [:create]

	before_action :authorize_user, except: [:index, :create]

	include ApiHelper


	# apipie documentation block
	resource_description do
	  short 'Superclass of Student and Lecturer'
	  name 'User'
	  api_base_url '/v1/users'
	  api_version 'v1'
	  description 'User is authenticatable. '
	end


	api :POST, '/register', 'Register a new user using email and password as authentication'
	description 'Used to register a new User resource that is authenticatable with email and password. For registering a user with OAuth please refer to <link>.'
	param :email, String,									'A unique email', 								required: true, missing_message: "can't be blank"
	param :password, String,							'Minimum 8 characters', 					required: true, missing_message: "can't be blank"
	param :password_confirmation, String, 'Must equal the password param', 	required: true, missing_message: "can't be blank"
	param :first_name, String,						"User's first name", 							required: true, missing_message: "can't be blank"
	param :last_name, String,							"User's last name", 							required: true, missing_message: "can't be blank"
	error code: 400, desc: 'Params missing. Did not receive either email, password or password_confirmation in params. See errors in response body.'
	error code: 422, desc: "Failed to save User. Params are invalid. See errors in response body."
	example " 'email': 'email@email.com', 'password': '12345678', 'password_confirmation': '12345678', 'first_name': 'Bob', 'last_name': 'Lastnamovic' "
	#####
	def create
		if !user_params['email'] || !user_params['password'] || !user_params['password_confirmation']
			render json: '', status: :bad_request
			return
		end

		@user = User.new(user_params).process_new_record

		if @user.save
			render json: '', status: :created
		else
			render json: format_errors(@user.errors), status: :unprocessable_entity
		end
	end


	# PUT update
	# required params: id, current_password (only if password is to be updated)
	def update
		update_method = user_params[:current_password] ? 'update_with_password' : 'update_without_password'

		if @user.method(update_method).call(user_params.except(:provider))
			render json: @user, status: :ok
		else
			render json: format_errors(@user.errors), status: :unprocessable_entity
		end
	end


	# DELETE destroy
	# required params: id, current_password
	def destroy
		if @user.destroy_with_password(user_params[:current_password])
			render json: '', status: :no_content
		else
			render json: format_errors(@user.errors), status: :unprocessable_entity
		end
	end


private

	def user_params
		params.permit(:id, :first_name, :last_name, :email, :password, :password_confirmation,
			:current_password, :provider)
	end

end
