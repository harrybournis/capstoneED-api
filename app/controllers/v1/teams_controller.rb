class V1::TeamsController < ApplicationController

	before_action :allow_if_lecturer, 		only: [:create, :destroy, :remove_student]
	before_action :allow_if_student,			only: [:enrol]
	before_action -> { allow_if_lecturer(index_with_project_error_message) }, only: :index_with_project
	before_action -> { allow_if_student(index_error_message) }, only: :index
 	before_action :validate_includes, only: [:index, :index_with_project, :show], if: 'params[:includes]'
  before_action :delete_includes_from_params, only: [:update, :destroy, :remove_student]
  before_action :set_team_if_associated, only: [:show, :update, :destroy, :remove_student]


	# GET /teams
	# Only for Students
	def index
		serialize_collection current_user.teams(includes: includes_array), :ok
	end

	# GET /teams?project_id=
	# Only for Lecturers
	def index_with_project
		@teams = current_user.teams(includes: includes_array).where(['projects.id = ?', params[:project_id]])
		serialize_collection @teams, :ok
	end

	# GET /teams/:id
	def show
		serialize_object @team, :ok
	end

	# POST /teams
	def create
    unless @project = current_user.projects.where(id: params[:project_id])[0]
      render_not_associated_with_current_user('Project')
      return false
    end

		team = Team.new(team_params)

		if team.save
			render json: team, status: :created
		else
			render json: format_errors(team.errors), status: :unprocessable_entity
		end
	end

	# PATCH /teams/:id
	def update
		params.delete(:enrollment_key) if current_user.load.instance_of? Student

		if @team.update(team_update_params)
			render json: @team, status: :ok
		else
			render json: format_errors(@team.errors), status: :unprocessable_entity
		end
	end

	# DELETE /teams/:id
	def destroy
		if @team.destroy
			render json: '', status: :no_content
		else
			render json: format_errors(@team.errors), status: :unprocessable_entity
		end
	end


	# POST /teams/enrol
	# Needs enrollemnt_key in params
	def enrol
		if @team = Team.find_by(enrollment_key: params[:enrollment_key])
			if @team.enrol(current_user.load)
				render json: @team, status: :created
			else
				render json: format_errors(@team.errors), status: :forbidden
			end
		else
			render json: format_errors({ enrollment_key: ['is invalid'] })
		end
	end

	# DELETE /teams/:id/remove_student
	# Only for Lecturer
	def remove_student
		unless params[:student_id]
			render json: format_errors({ student_id: ["can't be blank"] }), status: :bad_request
			return
		end

		if student = @team.students.find_by(id: params[:student_id])
			@team.students.delete(student)
			render json: '', status: 204
		else
			render json: format_errors({ base: ["Can't find Student with id #{params[:student_id]} in this Team."] }), status: :unprocessable_entity
		end
	end


	private

    # Sets @team if it is asociated with the current user. Eager loads associations in the params[:includes].
    # Renders error if not associated and Halts execution
    def set_team_if_associated
      unless @team = current_user.teams(includes: includes_array).where(id: params[:id])[0]
        render_not_associated_with_current_user('Team')
        return false
      end
    end

    # The class of the resource that the controller handles
    def controller_resource
      Team
    end

    # Strong Params
		def team_params
			params.permit(:name, :logo, :enrollment_key, :student_id, :project_id)
		end

		def team_update_params
			params.permit(:name, :logo, :enrollment_key)
		end

		def index_with_project_error_message
			"Students can not access this route with a 'project_id' in the parameters. Retry without it."
		end

		def index_error_message
			"Lecturers must provide a 'project_id' in the parameters for this route."
		end
end
