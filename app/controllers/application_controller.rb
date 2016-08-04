class ApplicationController < ActionController::API
	before_action :configure_permitted_parameters, if: :devise_controller?

	include DeviseTokenAuth::Concerns::SetUserByToken


protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :is_admin, :confirm_success_url, :config_name, :registration])
		devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :is_admin])
	end
end
