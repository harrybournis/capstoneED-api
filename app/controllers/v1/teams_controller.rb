class V1::TeamsController < ApplicationController

	before_action :set_team_if_owner, only: [:show]

	def index
		if current_user.load.instance_of? Lecturer
			index_for_lecturer
		else
			index_for_student
		end
	end

	def show
		render json: @team, status: :ok
	end


	private

		# Will be called in the Index Action if the current_user is a Lecturer
		def index_for_lecturer
			if team_params[:project_id]
				render json: @project.teams, status: :ok if set_project_if_owner
			else
				render json: format_errors({ project_id: ["can't be blank"] }), status: 400
			end
		end

		# Will be called in the Index Action if the current_user is a Student
		def index_for_student
			render json: current_user.load.teams, status: :ok
		end

		# REFACTOR
    def set_project_if_owner
      @project = Project.find_by(id: team_params[:project_id])
      unless current_user.load.projects.include? @project
        render json: format_errors({ base: ["This Project can not be found in the current user's Projects"] }), status: :forbidden
        return false
      end
      true
    end

    def set_team_if_owner
    	@team = Team.find_by(id: team_params[:id])
    	unless current_user.load.teams.include? @team
    		render json: format_errors({ base: ["This Team can not be found in the current user's Teams"] }), status: :forbidden
    	end
    	true
    end

		def team_params
			params.permit(:id, :name, :logo, :enrollment_key, :student_id, :project_id)
		end
end
