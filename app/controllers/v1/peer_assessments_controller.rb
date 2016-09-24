class V1::PeerAssessmentsController < ApplicationController

	# GET /peer_assessments?pa_form_id=2
	def index_with_pa_form

	end

	# GET /peer_assessments?submitted_for_id=2
	def index_with_submitted_for
	end

	# GET /peer_assessments?submitted_by_id=2
	def index_with_submitted_by
	end

	# GET /peer_assessments
	def index
	end

	# GET /peer_assessments/:id
	def show
	end

	# POST /peer_assessments
	def create
	end


	private

		def peer_assessments_params
			params.permit(:pa_form, :submitted_for_id, :submitted_by_id, :date_submitted, :answers)
		end
end
