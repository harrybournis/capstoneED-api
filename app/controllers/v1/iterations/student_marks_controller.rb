class V1::Iterations::StudentMarksController < ApplicationController
  before_action :allow_if_lecturer, only: :show
  before_action :set_iteration_if_association, only: :show

  # GET /scored-iterations/:id/marks
  def index
    pa_form = @iteration.pa_form
    ans_tables = []
    @iteration.projects.each do |project|
      ans_tables << Marking::PaAnswersTable.new(project, pa_form)
    end

    render json: ans_tables, serializer_each: PaAnswersTableSerializer, status: :ok
  end

  private

  def set_iteration_if_association
    unless @iteration = current_user.scored_iterations.eager_load(:iteration_marks, :pa_form, projects: [:students]).where(id: params[:id])[0]
      render_not_associated_with_current_user('Scored Iteration')
      false
    end
  end
end
