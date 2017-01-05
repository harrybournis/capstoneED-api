class V1::FeelingsController < ApplicationController

	def index
		render json: Feeling.all, status: :ok
	end

end
