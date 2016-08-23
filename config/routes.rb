Rails.application.routes.draw do

	#constraints subdomain: "api" do
		namespace :v1, constraints: { format: 'json' } do
			devise_for :users, skip: [:sessions], skip_helpers: true, controllers: {
				confirmations: 'v1/confirmations',
				passwords: 		 'v1/passwords'
			}
			resources :users, only: [:update, :destroy]
			post 	'/users/register',	to: 'users#create'



			# Authentication Routes
			get 	'me', 		  to: 'authentications#me'
			post	'sign_in',	to: 'authentications#sign_in_email'
			post	'sign_out',	to: 'authentications#sign_out'
			post	'refresh', 	to: 'authentications#refresh'
		end
	#end

	## To be removed
	post 'auth/facebook', to: 'authentications#facebook'
	post 'omniauth/facebook', to: 'authentications#facebook'
	##

	apipie
end
