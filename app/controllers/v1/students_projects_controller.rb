class V1::StudentsProjectsController < ApplicationController

	before_action :allow_if_student, only: [:enrol, :update_nickname, :update_logs, :index_logs_student]
	before_action :allow_if_lecturer, only: [:remove_student, :index_logs_lecturer]
  before_action :delete_includes_from_params, only: [:remove_student]
  before_action :set_project_if_associated, only: [:remove_student, :index_logs_lecturer]
  before_action :set_students_project_if_associated, only: [:update_nickname, :update_logs, :index_logs_student]

	# POST /projects/enrol
	# Needs enrollment_key and id in params
	def enrol
		unless @project = Project.find_by(id: params[:id])
			render json: format_errors({id: ['does not exist']}), status: :unprocessable_entity
			return
		end

		if @project.enrol(current_user.load, params[:enrollment_key], params[:nickname])
			render json: @project, serializer: ProjectStudentSerializer, status: :created
		else
			render json: format_errors(@project.errors), status: :forbidden
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
			render json: format_errors({ base: ["Can't find Student with the provided id in this Project."] }), status: :unprocessable_entity
		end
	end

	# PATCH /projects/update_nickname
	# Only for Student
	def update_nickname
		unless params[:nickname]
			render json: format_errors({ nickname: ["was not provided"] }), status: :unprocessable_entity
			return
		end

		if @students_project.update(nickname: params[:nickname])
			render json: { nickname: params[:nickname] }, status: :ok
		else
			render json: format_errors(@students_project.errors), status: :unprocessable_entity
		end
	end

	# GET /projects/:id/logs
	# Only for Student
	def index_logs_student
		render json: { logs: @students_project.logs }, status: :ok
	end

	# GET /projects/:id/logs
	# Only for lecturer
	# Needs student_id in params
	def index_logs_lecturer
    unless @students_project = JoinTables::StudentsProject.where(student_id: params[:student_id], project_id: params[:id])[0]
      render json: format_errors({ student_id: ['does not belong to this project'] }), status: :unprocessable_entity
      return
    end

    render json: { logs: @students_project.logs }, status: :ok
	end

	# POST /projects/:id/update_logs
	# Only for Student
	def update_logs
		@students_project.add_log(log_params.to_h.to_h)

		if @students_project.save
			render json: { log_entry: @students_project.logs.last }, status: :ok
		else
			render json: format_errors(@students_project.errors), status: :unprocessable_entity
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

	  # Sets @=project if it is asociated with the current user. Eager loads associations in the params[:includes].
    # Renders error if not associated and Halts execution
    def set_students_project_if_associated
      unless @students_project = JoinTables::StudentsProject.where(student_id: current_user.id, project_id: params[:id])[0]
        render_not_associated_with_current_user('Project')
        return false
      end
    end

    def log_params
    	params.permit(:date_worked, :time_worked, :stage, :text)
    end

end
