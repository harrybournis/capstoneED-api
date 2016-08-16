class V1::UsersController < ApplicationController

	skip_before_action :authenticate_user_jwt, only: [:create]

	before_action :set_user, except: [:index, :create]
	before_action :wrap_params, except: [:index]

	def index
		@users = User.all
		render json: @users
	end

	def create
		if !@params_wrapper.email || !@params_wrapper.password || !@params_wrapper.password_confirmation
			render json: :none, status: :bad_request
			return
		end

		@user = User.new(user_params).process_new_record

		if @user.save
			render json: :none, status: :created
		else
			render json: @user.errors, status: :unprocessable_entity
		end
	end

private

	def wrap_params
		@params_wrapper = UserParamsWrapper.new(user_params)
	end

	def set_user
		@user = User.find(params[:id])
	end

	def user_params
		params.permit(:first_name, :last_name, :email, :password, :password_confirmation, :provider)
	end
end
