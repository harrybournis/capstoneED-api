class V1::IterationsController < ApplicationController

	before_action :validate_project_id_present, 							only: [:index]
	before_action :validate_project_belongs_to_current_user, 	only: [:index, :create]
	before_action :allow_if_lecturer, 												only: :create
	before_action only: [:index, :show], if: 'params[:includes]' do
    validate_includes(current_user.iteration_associations, includes_array, 'Iteration')
  end
  before_action :set_iteration_if_associated, 							only: [:show, :update, :destroy]


	# GET /iterations?project_id=
	# Needs project_id in params
	def index
		if (@iterations = current_user.iterations(includes: params[:includes]).where(project_id: params[:project_id])).empty?
      render_not_associated_with_current_user('Iteration')
      return false
    end
    serialize_collection @iterations, :ok
	end

	# GET /iterations/:id
	def show
		serialize_object @iteration, :ok
	end

	# POST /iterations
	# Only for Lecturers
	def create
		@iteration = Iteration.create(iteration_params)

		if @iteration.save
			render json: @iteration, status: :created
		else
			render json: format_errors(@iteration.errors), status: :unprocessable_entity
		end
	end

	# PATCH /iterations/:id
	def update
		if @iteration.update(iteration_update_params)
			render json: @iteration, status: :ok
		else
			render json: @iteration.errors, status: :ok
		end
	end

	# DELETE /iterations/:id
	def destroy
		@iteration.destroy
		render json: '', status: :no_content
	end


	private

    # Sets @team if it is asociated with the current user. Eager loads associations in the params[:includes].
    # Renders error if not associated and Halts execution
    def set_iteration_if_associated
      unless @iteration = current_user.iterations(includes: includes_array).where(id: params[:id])[0]
        render_not_associated_with_current_user('Iteration')
        return false
      end
    end

    def validate_project_id_present
			unless params[:project_id]
				render json: format_errors({ base: ['This Endpoint requires a project_id in the params'] }), status: :bad_request
				return
			end
    end

    def validate_project_belongs_to_current_user
			unless current_user.projects.find_by( id: params[:project_id])
				render json: format_errors({ project_id: ["is not one of current user's projects"] }), status: :forbidden
				return
			end
    end

    # The class of the resource that the controller handles
    def controller_resource
      Iteration
    end

    def iteration_params
    	params.permit(:name, :start_date, :deadline, :project_id, pa_form_attributes: [questions: []])
    end

    def iteration_update_params
    	params.permit(:name, :start_date, :deadline)
    end
end
