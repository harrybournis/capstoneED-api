class V1::TeamsController < ApplicationController

	before_action :allow_if_lecturer, 		only: [:create, :destroy]
	before_action :allow_if_student,			only: [:enrol]
	before_action :set_project_if_owner,	only: [:create]
	before_action :set_team_if_owner, 		only: [:show, :update, :destroy]
	#before_action -> { set_if_owner(Project, params[:project_id]) },    only: [:create]
	#before_action -> { set_if_owner(Team, params[:id]) },    only: [:show, :update, :destroy]

	def index
		if current_user.load.instance_of? Lecturer

			if team_params[:project_id]
				render json: @project.teams, status: :ok if set_project_if_owner
			else
				render json: format_errors({ project_id: ["can't be blank"] }), status: 400
			end

		else
			render json: current_user.load.teams, status: :ok
		end
	end


	def show
		render json: @team, status: :ok
	end


	def create
		team = Team.new(team_params)

		if team.save
			render json: team, status: :created
		else
			render json: format_errors(team.errors), status: :unprocessable_entity
		end
	end


	def enrol
		if @team = Team.find_by(enrollment_key: params[:enrollment_key])

			if @team.enrol(current_user.load)
				render json: @team, status: :created
			else
				render json: format_errors(@team.errors), status: :forbidden
			end

		else
			render json: format_errors({ enrollment_key: ['is invalid'] })
		end
	end


	def update
		params.delete(:enrollment_key) if current_user.load.instance_of? Student

		if @team.update(team_update_params)
			render json: @team, status: :ok
		else
			render json: format_errors(@team.errors), status: :unprocessable_entity
		end
	end


	def destroy
		if @team.destroy
			render json: '', status: :no_content
		else
			render json: format_errors(@team.errors), status: :unprocessable_entity
		end
	end


	private

		# REFACTOR
    def set_project_if_owner
      @project = Project.find_by(id: params[:project_id])
      unless current_user.load.projects.include? @project
        render json: format_errors({ base: ["This Project can not be found in the current user's Projects"] }), status: :forbidden
        return false
      end
      true
    end

    def set_team_if_owner
    	@team = Team.find_by(id: params[:id])
    	unless current_user.load.teams.include? @team
    		render json: format_errors({ base: ["This Team can not be found in the current user's Teams"] }), status: :forbidden
    	end
    	true
    end

		def team_params
			params.permit(:name, :logo, :enrollment_key, :student_id, :project_id)
		end

		def team_update_params
			params.permit(:name, :logo, :enrollment_key)
		end
end
