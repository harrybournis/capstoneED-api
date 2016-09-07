class V1::TeamsController < ApplicationController

	before_action :allow_if_lecturer, 		only: [:create, :destroy]
	before_action :allow_if_student,			only: [:enrol]
	before_action -> {
		set_if_owner(Project, params[:project_id], '@project') }, only: [:create]
	before_action -> {
		set_if_owner(Team, params[:id], '@team') }, 							only: [:show, :update, :destroy]

	# GET /teams
	# Lecturer: Must provide project_id, teams for that Project
	# Student: 	All their teams
	def index
		if current_user.load.instance_of? Lecturer
			if team_params[:project_id]
				serialize_collection_params @project.teams, :ok if set_if_owner(Project, params[:project_id], '@project', 'teams')
			else
				render json: format_errors({ project_id: ["can't be blank"] }), status: 400
			end
		else
			serialize_collection_params current_user.load.teams, :ok
		end
	end

	# GET /teams/:id
	def show
		serialize_params @team, :ok
	end

	# POST /teams
	def create
		team = Team.new(team_params)

		if team.save
			render json: team, status: :created
		else
			render json: format_errors(team.errors), status: :unprocessable_entity
		end
	end

	# POST /teams/enrol
	# Needs enrollemnt_key in params
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

	# PATCH /teams/:id
	def update
		params.delete(:enrollment_key) if current_user.load.instance_of? Student

		if @team.update(team_update_params)
			render json: @team, status: :ok
		else
			render json: format_errors(@team.errors), status: :unprocessable_entity
		end
	end

	# DELETE /teams/:id
	def destroy
		if @team.destroy
			render json: '', status: :no_content
		else
			render json: format_errors(@team.errors), status: :unprocessable_entity
		end
	end


	private

		def team_params
			params.permit(:name, :logo, :enrollment_key, :student_id, :project_id)
		end

		def team_update_params
			params.permit(:name, :logo, :enrollment_key)
		end
end
