class V1::ProjectsController < ApplicationController

	before_action :allow_if_lecturer, 		only: [:create, :destroy]
	before_action -> { allow_if_lecturer(index_with_assignment_error_message) }, only: :index_with_assignment
	before_action -> { allow_if_lecturer(index_with_unit_error_message) }, only: :index_with_unit
	#before_action -> { allow_if_student(index_error_message) }, only: :index
 	before_action :validate_includes, only: [:index, :index_with_assignment, :index_with_unit, :show], if: 'params[:includes]'
  before_action :delete_includes_from_params, only: [:update, :destroy]
  before_action :set_project_if_associated, only: [:show, :update, :destroy]


	# GET /projects
	# Only for Students
	def index
		if current_user.student?
			serialize_collection current_user.projects(includes: includes_array).active, :ok, ProjectStudentSerializer
		else
			serialize_collection current_user.projects(includes: includes_array).active, :ok
		end
	end

	# GET /projects?assignment_id=
	# Only for Lecturers
	def index_with_assignment
		@projects = current_user.projects(includes: includes_array).where(['assignments.id = ?', params[:assignment_id]])
		serialize_collection @projects, :ok
	end

	# GET /projects?unit_id=
	# Only for Lecturers
	def index_with_unit
		@projects = current_user.projects(includes: includes_array).where(['projects.unit_id = ?', params[:unit_id]])
		serialize_collection @projects, :ok
	end

	# GET /projects/:id
	def show
		if current_user.student?
			serialize_object @project, :ok, ProjectStudentSerializer
		else
			serialize_object @project, :ok
		end
	end

	# POST /projects
	def create
    unless assignment = current_user.assignments.where(id: params[:assignment_id])[0]
      render_not_associated_with_current_user('Assignment')
      return false
    end

		project = Project.new(project_params)

		if project.save
			render json: project, status: :created
		else
			render json: format_errors(project.errors), status: :unprocessable_entity
		end
	end

	# PATCH /projects/:id
	def update
		if project_update_params.empty?
			render json: format_errors({ base: ["none of the given parameters can be updated by the current user"] }), status: :bad_request
			return
		end

		if @project.update(project_update_params)
			render json: @project, status: :ok
		else
			render json: format_errors(@project.errors), status: :unprocessable_entity
		end
	end

	# DELETE /projects/:id
	def destroy
		if @project.destroy
			render json: '', status: :no_content
		else
			render json: format_errors(@project.errors), status: :unprocessable_entity
		end
	end


	private

    # Sets @project if it is asociated with the current user. Eager loads associations in the params[:includes].
    # Renders error if not associated and Halts execution
    def set_project_if_associated
      unless @project = current_user.projects(includes: includes_array).where(id: params[:id])[0]
        render_not_associated_with_current_user('Project')
        return false
      end
    end

    # The class of the resource that the controller handles
    def controller_resource
      Project
    end

    # Strong Params
		def project_params
			params.permit(:project_name, :team_name, :description, :logo, :enrollment_key, :student_id, :assignment_id)
		end

		def project_update_params
			if current_user.type == "Lecturer"
				params.permit(:project_name, :team_name, :description, :logo, :enrollment_key)
			else
				params.permit(:team_name, :logo)
			end
		end

		def index_with_assignment_error_message
			"Students can not access this route with a 'assignment_id' in the parameters. Retry without it."
		end

		def index_with_unit_error_message
			"Students can not access this route with a 'unit_id' in the parameters. Retry without it."
		end

		def index_error_message
			"Lecturers must provide a 'assignment_id' or a 'unit_id' in the parameters for this route."
		end
end
