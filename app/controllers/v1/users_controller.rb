class V1::UsersController < ApplicationController

	before_action :set_user, except: [:index, :create]
	skip_before_action :authenticate_user_jwt, only: [:create]

	def index
		@users = User.all
		render json: @users
	end

	def create
		render json: :none, status: :bad_request unless params['email'] || params['password'] || params['password-confirmation']
	end

private

	def set_user
		@user = User.find(params[:id])
	end

	def user_params
		params.require(:user).permit(:id, :first_name, :last_name, :email)
	end
end
