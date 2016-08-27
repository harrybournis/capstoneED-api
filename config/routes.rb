Rails.application.routes.draw do

	#constraints subdomain: "api" do
		namespace :v1, constraints: { format: 'json' } do

			# Authentication Routes
			get 		'me', 		  to: 'authentications#me'
			post		'sign_in',	to: 'authentications#sign_in_email'
			delete	'sign_out',	to: 'authentications#sign_out'
			post		'refresh', 	to: 'authentications#refresh'

			# User Routes
			resources :students, only: [:update, :destroy]
			post 	'/students/register',	to: 'students#create'

			resources :lecturers, only: [:update, :destroy]
			post 	'/lecturers/register',	to: 'lecturers#create'

			devise_for :users, skip: [:sessions], skip_helpers: true, controllers: {
				confirmations: 'v1/confirmations',
				passwords: 		 'v1/passwords'
			}


			# Departments
			resources :departments, only: [:create, :update, :destroy]
		end
	#end

	## To be removed
	post 'auth/facebook', to: 'authentications#facebook'
	post 'omniauth/facebook', to: 'authentications#facebook'
	##

	apipie
end
