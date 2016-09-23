Rails.application.routes.draw do

	#constraints subdomain: "api" do
		namespace :v1, constraints: { format: 'json' } do

			# Authentication Routes
			get 		'me', 		  to: 'authentications#me'
			post		'sign_in',	to: 'authentications#sign_in_email'
			delete	'sign_out',	to: 'authentications#sign_out'
			post		'refresh', 	to: 'authentications#refresh'

			# Users
			devise_for :users, skip: [:sessions], skip_helpers: true, controllers: {
				confirmations: 'v1/confirmations',
				passwords: 		 'v1/passwords'
			}
			resources :users,				only: [:create, :update]

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
			delete 'teams/:id/remove_student', to: 'teams#remove_student'
			resources :teams

			# Custom Questions
			resources :questions

			# Iterations
			get 'iterations', 			to: 'iterations#index', constraints: -> (request) { request.params[:project_id] }
			resources :iterations, 					 only: [:index, :show, :create, :update, :destroy]

			# PAForms
			resources :pa_forms, only: [:show, :create]
		end
	#end

	## To be removed
	#post 'auth/facebook', to: 'authentications#facebook'
	#post 'omniauth/facebook', to: 'authentications#facebook'
	##

	apipie
end
