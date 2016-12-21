class V1::ProjectEvaluationsController < ApplicationController

	before_action :allow_if_lecturer, only: [:update]
	before_action :set_project_evaluation_if_associated, only: :update

	# POST /project_evaluations
	def create
		pe = ProjectEvaluation.new(project_evaluations_params)
		pe.user = current_user.load

		if pe.save
			render json: pe, status: :created
		else
			render json: format_errors(pe.errors), status: :unprocessable_entity
		end
	end

	# PATCH /project_evaluations?id=2
	# only for lecturers
	def update
		if @pe.update(update_project_evaluation_params)
			render json: @pe, status: :ok
		else
			render json: format_errors(@pe.errors), status: :unprocessable_entity
		end
	end


	private

    # Sets @pe if it is asociated with the current user.
    def set_project_evaluation_if_associated
      unless @pe = current_user.project_evaluations.where(id: params[:id])[0]
        render_not_associated_with_current_user('Project Evaluation')
        return false
      end
    end

    # The class of the resource that the controller handles
    def controller_resource
      ProjectEvaluation
    end

		def project_evaluations_params
			params.permit(:project_id, :iteration_id, :feeling_id, :percent_complete)
		end

		def update_project_evaluation_params
			params.permit(:id, :feeling_id, :percent_complete)
		end
end
