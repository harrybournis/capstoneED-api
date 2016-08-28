Rails.application.routes.draw do

	#constraints subdomain: "api" do
		namespace :v1, constraints: { format: 'json' } do

			# Authentication Routes
			get 		'me', 		  to: 'authentications#me'
			post		'sign_in',	to: 'authentications#sign_in_email'
			delete	'sign_out',	to: 'authentications#sign_out'
			post		'refresh', 	to: 'authentications#refresh'

			# User
			devise_for :users, skip: [:sessions], skip_helpers: true, controllers: {
				confirmations: 'v1/confirmations',
				passwords: 		 'v1/passwords'
			}

			# Students
			post '/students/register', 	to: 'students#create'
			resources :students, 	only:	[:update, :destroy]


			# Lecturers
			post '/lecturers/register', to: 'lecturers#create'
			resources :lecturers, only:	[:update, :destroy] do
							resources :units
			end







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
