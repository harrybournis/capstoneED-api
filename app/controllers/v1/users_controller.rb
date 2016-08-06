class V1::UsersController < ApplicationController

	before_action :authenticate_v1_user!
	#before_action :set_user, except: [:index]

SKATA
private

	def set_user
		@user = User.find(params[:id])
	end

	def user_params
		params.require(:user).permit(:id, :first_name, :last_name, :email, :is_admin, :email,
			:password, :password_confirmation)
	end
end
