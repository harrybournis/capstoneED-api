class V1::UsersController < ApplicationController

	skip_before_action :authenticate_user_jwt, only: [:create]

	before_action :authorize_user, except: [:index, :create]

	include ApiHelper

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
