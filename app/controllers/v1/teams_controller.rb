class V1::TeamsController < ApplicationController

	def index
		render json: current_user.load.teams, response: :ok
	end

end
