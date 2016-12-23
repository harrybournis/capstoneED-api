class V1::ProjectsController < ApplicationController

	before_action :allow_if_lecturer, 		only: [:create, :destroy, :remove_student]
	before_action :allow_if_student,			only: [:enrol]
	before_action -> { allow_if_lecturer(index_with_assignment_error_message) }, only: :index_with_assignment
	before_action -> { allow_if_student(index_error_message) }, only: :index
 	before_action :validate_includes, only: [:index, :index_with_assignment, :show], if: 'params[:includes]'
  before_action :delete_includes_from_params, only: [:update, :destroy, :remove_student]
  before_action :set_project_if_associated, only: [:show, :update, :destroy, :remove_student]


	# GET /projects
	# Only for Students
	def index
		serialize_collection current_user.projects(includes: includes_array), :ok
	end

	# GET /projects?assignment_id=
	# Only for Lecturers
	def index_with_assignment
		@projects = current_user.projects(includes: includes_array).where(['assignments.id = ?', params[:assignment_id]])
		serialize_collection @projects, :ok
	end

	# GET /projects/:id
	def show
		serialize_object @project, :ok
	end

	# POST /projects
	def create
    unless @project = current_user.assignments.where(id: params[:assignment_id])[0]
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
		params.delete(:enrollment_key) if current_user.load.instance_of? Student

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


	# POST /projects/enrol
	# Needs enrollemnt_key and id in params
	def enrol
		unless @project = Project.find_by(id: params[:id])
			render json: format_errors({id: ['does not exist']}), status: :unprocessable_entity
			return
		end

		if @project.enrollment_key == params[:enrollment_key]
			if @project.enrol(current_user.load)
				render json: @project, status: :created
			else
				render json: format_errors(@project.errors), status: :forbidden
			end
		else
			render json: format_errors({ enrollment_key: ['is invalid'] })
		end
	end

	# DELETE /project/:id/remove_student
	# Only for Lecturer
	def remove_student
		unless params[:student_id]
			render json: format_errors({ student_id: ["can't be blank"] }), status: :bad_request
			return
		end

		if student = @project.students.find_by(id: params[:student_id])
			@project.students.delete(student)
			render json: '', status: 204
		else
			render json: format_errors({ base: ["Can't find Student with id #{params[:student_id]} in this Project."] }), status: :unprocessable_entity
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
			params.permit(:project_name, :team_name, :description, :logo, :enrollment_key)
		end

		def index_with_assignment_error_message
			"Students can not access this route with a 'assignment_id' in the parameters. Retry without it."
		end

		def index_error_message
			"Lecturers must provide a 'assignment_id' in the parameters for this route."
		end
end
