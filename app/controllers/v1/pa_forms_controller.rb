## PAForms Controller
class V1::PaFormsController < ApplicationController
  before_action :allow_if_lecturer, only: [:create, :update, :destroy]
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

  def pa_form_wout_questions_params
    params.permit(:iteration_id)
  end
end
