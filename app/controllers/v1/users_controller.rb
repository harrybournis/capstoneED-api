class V1::UsersController < ApplicationController

	skip_before_action :authenticate_user_jwt, only: [:create]
	before_action :allow_if_self, only: [:update, :destroy]


	# POST '/register'
	# Register a new user using email and password as authentication
	def create
		unless User::USER_TYPES.include? params[:type]
			render json: format_errors({ type: ["must be either Student or Lecturer. Received: #{params[:type]}"] }), status: :unprocessable_entity
			return
		end

		@user = User.new(user_params).process_new_record

		if @user.save
			render json: @user, status: :created
		else
			render json: format_errors(@user.errors), status: :unprocessable_entity
		end
	end


	# PUT '/users/:id'
	# Requires current_password if password is to be updated
	def update
		update_method = user_params[:current_password] ? 'update_with_password' : 'update_without_password'

		if @user.method(update_method).call(user_params)
			render json: @user, status: :ok
		else
			render json: format_errors(@user.errors), status: :unprocessable_entity
		end
	end


	# DELETE destroy
	# Requires current_password
	# def destroy
	# 	if @user.destroy_with_password(user_params[:current_password])
	# 		render json: '', status: :no_content
	# 	else
	# 		render json: format_errors(@user.errors), status: :unprocessable_entity
	# 	end
	# end


private

	def allow_if_self
		if current_user.id.to_s == user_params[:id]
			@user = current_user.load
		else
			render json: format_errors({ user: ["User with id #{user_params[:id]} is not authorized to access this resourse." ]}),
				status: :forbidden
		end
	end

	def user_params
		params.permit(:id, :first_name, :last_name, :email, :password, :password_confirmation,
			:current_password, :university, :position, :type)
	end

end
