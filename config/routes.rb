Rails.application.routes.draw do

	constraints subdomain: "api" do
		namespace :v1 do
			resources :users

			# Authentication Routes
			post 'authentications_controller/google'
			post 'authentications_controller/facebook'
			post 'authentications_controller/email'
		end
	end

	## To be removed
	post 'auth/facebook', to: 'authentications#facebook'
	post 'omniauth/facebook', to: 'authentications#facebook'
	##
end
