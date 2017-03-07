Rails.application.routes.draw do

  namespace :v1, constraints: { format: 'json' } do

    # Authentication Routes
    get     'me',       to: 'authentications#me'
    post    'sign_in',  to: 'authentications#sign_in_email'
    post    'sign_out', to: 'authentications#sign_out'
    post    'refresh',  to: 'authentications#refresh'

    # Users
    devise_for :users, skip: [:sessions, :passwords, :confirmations], skip_helpers: true
    # Passwords
    post 'request_reset_password',  to: 'passwords#create'
    patch 'reset_password',         to: 'passwords#update'
    # Confirmation
    post 'resend_confirmation_email', to: 'confirmations#create'
    get 'confirm_account',          to: 'confirmations#show', as: 'confirmation'
    resources :users,             only: [:create, :update]

    # Units
    get     'units/archived',     to: 'units#index_archived'
    patch   'units/:id/archive',      to: 'units#archive'
    resources :units,             only: [:index, :show, :create, :update, :destroy, :options]

    # Departments
    resources :departments,       only: [:create, :update, :destroy]

    # Assignments
    get     'assignments',        to: 'assignments#index_with_unit', constraints: -> (request) { request.params[:unit_id] }
    resources :assignments,       only: [:index, :show, :create, :update, :destroy]

    # Projects
    get     'projects',                       to: 'projects#index_with_assignment', constraints: -> (request) { request.params[:assignment_id] }
    get     'projects',                       to: 'projects#index_with_unit', constraints: -> (request) { request.params[:unit_id] }
    get     'projects/:id/logs',              to: 'students_projects#index_logs_lecturer', constraints: -> (request) { request.params[:student_id] }
    get     'projects/:id/logs',              to: 'students_projects#index_logs_student'
    post    'projects/:id/logs',              to: 'students_projects#update_logs'
    post    'projects/enrol',                 to: 'students_projects#enrol'
    patch   'projects/:id/update_nickname',   to: 'students_projects#update_nickname'
    delete  'projects/:id/remove_student',    to: 'students_projects#remove_student'
    resources :projects do
      resources :extensions, only: [:create, :update, :destroy]
    end

    # Custom Questions
    resources :questions

    # Iterations
    get     'iterations',         to: 'iterations#index', constraints: -> (request) { request.params[:project_id] }
    resources :iterations,        only: [:index, :show, :create, :update, :destroy]

    # PAForms
    resources :pa_forms,          only: [:index, :show, :create]

    # Peer Assessments
    resources :peer_assessments,  only: [:index, :show, :create]

    # Project Evaluations
    get     'projects/:project_id/evaluations',   to: 'project_evaluations#index_with_project'
    get     'iterations/:iteration_id/evaluations',to: 'project_evaluations#index_with_iteration'
    resources :project_evaluations, only: [:create, :update]

    # Feelings
    resources :feelings, only: [:index]
  end

  ## To be removed
  #post 'auth/facebook', to: 'authentications#facebook'
  #post 'omniauth/facebook', to: 'authentications#facebook'
  ##
end
