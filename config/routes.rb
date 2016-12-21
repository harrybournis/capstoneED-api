Rails.application.routes.draw do

	root to: 'apipie/apipies#index', version: 'v1'
	#constraints subdomain: "api" do
		namespace :v1, constraints: { format: 'json' } do

			# Authentication Routes
			get 		'me', 		  to: 'authentications#me'
			post		'sign_in',	to: 'authentications#sign_in_email'
			post		'sign_out',	to: 'authentications#sign_out'
			post		'refresh', 	to: 'authentications#refresh'

			# Users
			devise_for :users, skip: [:sessions], skip_helpers: true, controllers: {
				confirmations: 'v1/confirmations',
				passwords: 		 'v1/passwords'
			}
			resources :users,							only: [:create, :update]

			# Units
			resources :units, 						only: [:index, :show, :create, :update, :destroy, :options]

			# Departments
			resources :departments, 			only: [:create, :update, :destroy]

			# Assignments
			get 		'assignments',				to: 'assignments#index_with_unit', constraints: -> (request) { request.params[:unit_id] }
			resources :assignments,				only: [:index, :show, :create, :update, :destroy]

			# Projects
			get 		'projects',										to: 'projects#index_with_assignment', constraints: -> (request) { request.params[:assignment_id] }
			post 		'projects/enrol', 						to: 'projects#enrol'
			delete 	'project/:id/remove_student',to: 'projects#remove_student'
			resources :projects do
				resources :extensions, only: [:create, :update, :destroy]
			end

			# Custom Questions
			resources :questions

			# Iterations
			get 		'iterations', 				to: 'iterations#index', constraints: -> (request) { request.params[:project_id] }
			resources :iterations, 				only: [:index, :show, :create, :update, :destroy]

			# PAForms
			resources :pa_forms, 					only: [:index, :show, :create]

			# Peer Assessments
			get 		'peer_assessments',		to: 'peer_assessments#index_with_submitted_for', constraints: -> (request) { request.params[:pa_form_id] && request.params[:submitted_for_id] }
			get 		'peer_assessments',		to: 'peer_assessments#index_with_submitted_by', constraints: -> (request) { request.params[:pa_form_id] && request.params[:submitted_by_id] }
			get 		'peer_assessments',		to: 'peer_assessments#index_with_pa_form', constraints: -> (request) { request.params[:pa_form_id] }
			resources :peer_assessments, 	only: [:index, :show, :create]

			# Project Evaluations
			get 		'project/:project_id/evaluations',		to: 'project_evaluations#index_with_project'
			get 		'iteration/:iteration_id/evaluations',to: 'project_evaluations#index_with_iteration'
			resources :project_evaluations, only: [:create, :update]
		end
	#end

	## To be removed
	#post 'auth/facebook', to: 'authentications#facebook'
	#post 'omniauth/facebook', to: 'authentications#facebook'
	##

	apipie
end
