class V1::ExtensionsController < ApplicationController

	before_action :allow_if_lecturer
	before_action :set_team_if_associated, only: [:update, :destroy]

	# POST /extensions
	def create
		unless current_user.pa_forms.where(id: params[:deliverable_id]).any? && current_user.teams.where(id: params[:team_id]).any?
			render_not_associated_with_current_user('PAForm or Team')
			return false
		end

		extension = Extension.new(extension_params)

		if extension.save
			render json: extension, status: :created
		else
			render json: format_errors(extension.errors), status: :unprocessable_entity
		end
	end

	# PATCH /extensions
	def update
		if @extension.update(update_extension_params)
			render json: @extension, status: :ok
		else
			render json: format_errors(@extension.errors), status: :unprocessable_entity
		end
	end

	def destroy
		if @extension.destroy
			render json: :none, status: :no_content
		else
			render json: format_errors(@extension.errors), status: :unprocessable_entity
		end
	end


	private

    # Sets @extension if it is asociated with the current user.
    # Renders error if not associated and Halts execution
    def set_team_if_associated
      unless @extension = current_user.extensions.where(id: params[:id])[0]
        render_not_associated_with_current_user('Extension')
        return false
      end
    end

		def extension_params
			params.permit(:team_id, :deliverable_id, :extra_time)
		end

		def update_extension_params
			params.permit(:extra_time)
		end
end
