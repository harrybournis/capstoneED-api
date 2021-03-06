## Students Projects Controller
class V1::StudentsProjectsController < ApplicationController
  before_action :allow_if_student,
                only: [:enrol, :update_nickname]
  before_action :allow_if_lecturer,
                only: :remove_student
  before_action :delete_includes_from_params, only: [:remove_student]
  before_action :set_project_if_associated,
                only: :remove_student
  before_action :set_students_project_if_associated,
                only: :update_nickname

  # POST /projects/enrol
  # Needs enrollment_key and id in params
  def enrol
    unless @project = Project.find_by(id: params[:id])
      render json: format_errors(id: ['does not exist']),
             status: :unprocessable_entity
      return
    end

    if @project.enrol(current_user.load, params[:enrollment_key], params[:nickname])
      render json: @project,
             serializer: ProjectStudentSerializer,
            status: :created
    else
      render json: format_errors(@project.errors), status: :forbidden
    end
  end

  # DELETE /project/:id/remove_student
  # Only for Lecturer
  def remove_student
    unless params[:student_id]
      render json: format_errors(student_id: ["can't be blank"]),
             status: :bad_request
      return
    end

    if student = @project.students.find_by(id: params[:student_id])
      @project.students.delete(student)
      render json: '', status: 204
    else
      render json: format_errors({ base: ["Can't find Student with the provided id in this Project."] }),
             status: :unprocessable_entity
    end
  end

  # PATCH /projects/update_nickname
  # Only for Student
  def update_nickname
    unless params[:nickname]
      render json: format_errors(nickname: ['was not provided']),
             status: :unprocessable_entity
      return
    end

    if @students_project.update(nickname: params[:nickname])
      render json: { nickname: params[:nickname] }, status: :ok
    else
      render json: format_errors(@students_project.errors),
             status: :unprocessable_entity
    end
  end

  private

  # Sets @project if it is asociated with the current user.
  # Eager loads associations in the params[:includes].
  # Renders error if not associated and Halts execution
  def set_project_if_associated
    unless @project = current_user.projects(includes: includes_array)
                                  .where(id: params[:id])[0]
      render_not_associated_with_current_user('Project')
      false
    end
  end

  # Sets @project if it is asociated with the current user.
  # Eager loads associations in the params[:includes].
  # Renders error if not associated and Halts execution
  def set_students_project_if_associated
    unless @students_project =  StudentsProject.where(student_id: current_user.id, project_id: params[:id])[0]
      render_not_associated_with_current_user('Project')
      false
    end
  end
end
