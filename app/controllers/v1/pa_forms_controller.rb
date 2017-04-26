## PAForms Controller
class V1::PaFormsController < ApplicationController
  before_action :allow_if_lecturer, only: [:create, :update, :destroy, :create_for_each_iteration]
  before_action :allow_if_student, only:  [:index]
  before_action :validate_includes,
                only: [:index, :show],
                if: 'params[:includes]'
  before_action :set_pa_form_if_associated, only: [:show, :update, :destroy]

  def index
    active_uncompleted = current_user.pa_forms(includes: includes_array)
                                     .where
                                     .not(id: current_user.peer_assessments_by
                                                          .select(:pa_form_id)
                                                          .collect(&:pa_form_id))
                                     .active

    serialize_collection active_uncompleted, :ok
  end

  # GET /pa_forms/:id
  def show
    serialize_object @pa_form, :ok
  end

  # POST /pa_forms
  def create
    unless current_user.iterations.where(id: params[:iteration_id])[0]
      render_not_associated_with_current_user('Iteration')
      return
    end

    @pa_form = PaForm.new(pa_form_params)

    if @pa_form.save
      SaveQuestionsService.new(@pa_form.questions, current_user.id).call
      render json: @pa_form, status: :created
    else
      render json: format_errors(@pa_form.errors), status: :unprocessable_entity
    end
  end


  # POST /assignments/:assignment_id/pa_forms
  def create_for_each_iteration
    # Return error if assignment_id not associated with current_user
    unless @assignment = current_user.assignments
                                     .where(id: params[:assignment_id])[0]
      render_not_associated_with_current_user('Assignment')
      return
    end

    # Return error if assignment has no iterations
    unless @assignment.iterations.length > 0
      render json: format_errors(base: ['This assignment has no Iterations.']), status: :unprocessable_entity
      return
    end

    # Return error if at least one iteration already has a pa_form
    unless @assignment.pa_forms.empty?
      render json: format_errors(base: ['An Iteration in this Assignment already contains a PaForm.']), status: :unprocessable_entity
      return
    end

    errors = []
    pa_forms = []
    PaForm.transaction do
      @assignment.iterations.each do |iteration|
        @pa_form = PaForm.new(pa_form_for_multiple_params)
        @pa_form.iteration_id = iteration.id
        unless @pa_form.save
          errors = @pa_form.errors
          raise ActiveRecord::Rollback
        end
        pa_forms << @pa_form
      end
    end

    if errors.empty?
      render json: pa_forms, status: :created
    else
      render json: format_errors(errors), status: :unprocessable_entity
    end
  rescue Exception => e
    render json: format_errors(e), status: :unprocessable_entity
  end

  # # PATCH /pa_forms/:id
  # def update
  #   @pa_form.store_questions(params[:questions])

  #   if @pa_form.save
  #     render json: @pa_form, status: :ok
  #   else
  #     render json: format_errors(@pa_form.errors), status: :unprocessable_entity
  #   end
  # end

  # # DELETE /pa_forms/:id
  # def destroy
  #   if @pa_form.destroy
  #     render json: '', status: :no_content
  #   else
  #     render json: format_errors(@pa_form.errors), status: :unprocessable_entity
  #   end
  # end

  private

  # Sets @pa_form if it is asociated with the current user. Eager loads
  # associations in the params[:includes].
  # Renders error if not associated and Halts execution
  def set_pa_form_if_associated
    unless @pa_form = current_user.pa_forms(includes: includes_array)
                                  .where(id: params[:id])[0]
      render_not_associated_with_current_user('PAForm')
      false
    end
  end

  # The class of the resource that the controller handles
  def controller_resource
    PaForm
  end

  def pa_form_params
    params.permit(:iteration_id, :start_date, :deadline, questions: [:text, :type_id])
  end

  def pa_form_for_multiple_params
    params.permit(:start_offset, :end_offset, questions: [:text, :type_id])
  end

  def pa_form_wout_questions_params
    params.permit(:iteration_id)
  end
end
