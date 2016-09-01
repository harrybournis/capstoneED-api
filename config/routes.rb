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
			resources :students, 		only:	[:create, :update, :destroy]

			# Lecturers
			resources :lecturers, 	only:	[:create, :update, :destroy]

			# Units
			resources :units, 			only: [:index, :show, :create, :update, :destroy]

			# Departments
			resources :departments, only: [:index, :show, :create, :update, :destroy]

			# Projects
			resources :projects,		only: [:index, :show, :create, :update, :destroy]

			# Teams
			resources :teams,				only: [:index, :show, :create, :update, :destroy]
			post '/teams/enrol', 		to: 'teams#enrol'
		end
	#end

	## To be removed
	#post 'auth/facebook', to: 'authentications#facebook'
	#post 'omniauth/facebook', to: 'authentications#facebook'
	##

	apipie
end
