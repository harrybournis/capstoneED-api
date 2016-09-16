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
			resources :users,				only: [:create, :destroy, :update]

			# Students
			#resources :students, 		only:	[:update]

			# Lecturers
			#resources :lecturers, 	only:	[:update]

			# Units
			resources :units, 			only: [:index, :show, :create, :update, :destroy, :options]

			# Departments
			resources :departments, only: [:create, :update, :destroy]

			# Projects
			get 'projects',					to: 'projects#index_with_unit', constraints: -> (request) { request.params[:unit_id] }
			resources :projects,		only: [:index, :show, :create, :update, :destroy]

			# Teams
			get 'teams',						to: 'teams#index_with_project', constraints: -> (request) { request.params[:project_id] }
			post '/teams/enrol', 		to: 'teams#enrol'
			resources :teams

			# Custom Questions
			resources :custom_questions

			# Predefined Questions
			resources :predefined_questions, only: [:index, :show]

			# Iterations
			get 'iterations', 			to: 'iterations#index', constraints: -> (request) { request.params[:project_id] }
			resource :iterations, 					 only: [:index, :show, :create, :update, :destroy]
		end
	#end

	## To be removed
	#post 'auth/facebook', to: 'authentications#facebook'
	#post 'omniauth/facebook', to: 'authentications#facebook'
	##

	apipie
end
