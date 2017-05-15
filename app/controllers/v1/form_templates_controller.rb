# Controller for FormTemplate resource.
class V1::FormTemplatesController < ApplicationController
  before_action :allow_if_lecturer
  before_action :set_form_template_if_associated, only: [:update, :destroy]

  # GET /form_templates
  def index
    render json: current_user.form_templates, status: :ok
  end

  # POST /form_templates
  def create
    @form_template = FormTemplate.new(form_template_params)
    @form_template.lecturer = current_user.load

    if @form_template.save
      render json: @form_template, status: :created
    else
      render json: format_errors(@form_template.errors), status: :unprocessable_entity
    end
  end

  # PATCH /form_templates
  def update
    if @form_template.update(form_template_params)
      render json: @form_template, status: :ok
    else
      render json: format_errors(@form_template.errors), status: :unprocessable_entity
    end
  end

  # DELETE /form_templates
  def destroy
    if @form_template.destroy
      render json: '', status: :no_content
    else
      render json: format_errors(@form_template.errors), status: :unprocessable_entity
    end
  end

  private

  # Sets @form_template if it is asociated with the current user.
  # Renders error if not associated and Halts execution
  #
  def set_form_template_if_associated
    unless @form_template = current_user.form_templates.where(id: params[:id])[0]
      render_not_associated_with_current_user('Form Template')
      false
    end
  end

  # Strong params for FormTemplate
  def form_template_params
    params.permit(:name, questions: [:text, :type_id])
  end
end
