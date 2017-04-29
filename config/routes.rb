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
    devise_scope :v1_user do
      post 'request_reset_password', to: 'passwords#create'
      patch 'reset_password', to: 'passwords#update'
      # Confirmation
      post 'resend_confirmation_email', to: 'confirmations#create'
      get 'confirm_account', to: 'confirmations#show', as: 'confirmation'
    end
    resources :users, only: [:create, :update]

    # Units
    get 'units/archived', to: 'units#index_archived'
    patch 'units/:id/archive', to: 'units#archive'
    resources :units, only: [:index, :show, :create, :update, :destroy, :options]

    # Departments
    resources :departments, only: [:create, :update, :destroy]

    # Assignments
    get 'assignments', to: 'assignments#index_with_unit', constraints: -> (request) { request.params[:unit_id] }
    resources :assignments, only: [:index, :show, :create, :update, :destroy] do
      # Game Settings
      patch 'game_settings', to: 'game_settings#update'
      resources :game_settings, only: [:index, :create]
    end

    # Projects
    get     'projects', to: 'projects#index_with_assignment', constraints: -> (request) { request.params[:assignment_id] }
    get     'projects', to: 'projects#index_with_unit', constraints: -> (request) { request.params[:unit_id] }
    post    'projects/enrol', to: 'students_projects#enrol'
    patch   'projects/:id/update_nickname', to: 'students_projects#update_nickname'
    delete  'projects/:id/remove_student', to: 'students_projects#remove_student'
    resources :projects do
      resources :extensions, only: [:create, :update, :destroy]
    end

    # Logs
    get     'projects/:id/logs', to: 'logs#index_lecturer', constraints: -> (request) { request.params[:student_id] }
    get     'projects/:id/logs', to: 'logs#index_student'
    post    'projects/:id/logs', to: 'logs#update'

    # Custom Questions
    resources :questions, only: [:index]

    # Iterations
    get 'iterations', to: 'iterations#index', constraints: -> (request) { request.params[:project_id] }
    resources :iterations, only: [:index, :show, :create, :update, :destroy]

    # PAForms
    resources :pa_forms, only: [:index, :show, :create]
    post 'assignments/:assignment_id/pa_forms', to: 'pa_forms#create_for_each_iteration'

    # Peer Assessments
    resources :peer_assessments, only: [:index, :show, :create]

    # Project Evaluations
    get     'projects/:project_id/evaluations', to: 'project_evaluations#index_with_project'
    get     'iterations/:iteration_id/evaluations', to: 'project_evaluations#index_with_iteration'
    get     'project-evaluations', to: 'project_evaluations#index'
    post    'projects/:project_id/evaluations', to: 'project_evaluations#create'
    # patch   'projects/:project_id/evaluations', to: 'project_evaluations#update'

    # Feelings
    resources :feelings, only: [:index]

    # Question Types
    resources :question_types, only: [:index]

    # Points
    get 'projects/:project_id/points', to: 'points#index_for_project'
    get 'assignments/:assignment_id/points', to: 'points#index_for_assignment'

    # Reasons
    get 'reasons', to: 'reasons#index'

    # Form Templates
    resources :form_templates, only: [:index, :create, :update, :destroy]
  end

  ## To be removed
  # post 'auth/facebook', to: 'authentications#facebook'
  # post 'omniauth/facebook', to: 'authentications#facebook'
  ##
end
