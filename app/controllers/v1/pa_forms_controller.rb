class V1::PAFormsController < ApplicationController

	before_action :allow_if_lecturer, only: [:create, :update, :destroy]
  before_action only: [:show], if: 'params[:includes]' do
    validate_includes(current_user.pa_form_associations, includes_array, 'PAForm')
  end
  before_action :set_pa_form_if_associated, only: [:show, :update, :destroy]

	# def index
	# 	if iteration = current_user.iterations.where(id: params[:iteration_id])[0]
	# 		render json: iteration.pa_form, status: :ok
	# 	else
	# 		render_not_associated_with_current_user('Iteration')
	# 	end
	# end

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

		#@pa_form = PAForm.new(pa_form_wout_questions_params).store_questions(params[:questions])
		@pa_form = PAForm.new(pa_form_params)

		if @pa_form.save
			render json: @pa_form, status: :created
		else
			render json: format_errors(@pa_form.errors), status: :unprocessable_entity
		end
	end

	# # PATCH /pa_forms/:id
	# def update
	# 	@pa_form.store_questions(params[:questions])

	# 	if @pa_form.save
	# 		render json: @pa_form, status: :ok
	# 	else
	# 		render json: format_errors(@pa_form.errors), status: :unprocessable_entity
	# 	end
	# end

	# # DELETE /pa_forms/:id
	# def destroy
	# 	if @pa_form.destroy
	# 		render json: '', status: :no_content
	# 	else
	# 		render json: format_errors(@pa_form.errors), status: :unprocessable_entity
	# 	end
	# end


	private
    # Sets @team if it is asociated with the current user. Eager loads associations in the params[:includes].
    # Renders error if not associated and Halts execution
    def set_pa_form_if_associated
      unless @pa_form = current_user.pa_forms(includes: params[:includes]).where(id: params[:id])[0]
        render_not_associated_with_current_user('PAForm')
        return false
      end
    end

    def pa_form_params
    	params.permit(:iteration_id, questions: [])
    end

    def pa_form_wout_questions_params
    	params.permit(:iteration_id)
    end

end
