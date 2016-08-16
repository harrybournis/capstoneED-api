Rails.application.routes.draw do

	constraints subdomain: "api" do
		namespace :v1, constraints: { format: 'json' } do
			resources :users
			devise_for :users, skip: [:sessions], skip_helpers: true

			# Authentication Routes
			get 'validate', to: 'authentications#validate'
		end
	end

	## To be removed
	post 'auth/facebook', to: 'authentications#facebook'
	post 'omniauth/facebook', to: 'authentications#facebook'
	##
end
