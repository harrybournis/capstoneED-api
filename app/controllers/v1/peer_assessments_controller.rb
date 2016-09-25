class V1::PeerAssessmentsController < ApplicationController

  before_action only: [:index_with_pa_form], if: 'params[:includes]' do
    validate_includes(current_user.peer_assessment_associations, includes_array, 'Peer Assessment')
  end

	# GET /peer_assessments?pa_form_id=2
	def index_with_pa_form
		@peer_assessments = current_user.peer_assessments(includes: includes_array).where(['pa_form_id = ?', params[:pa_form_id]])
		binding.pry
		serialize_collection @peer_assessments, :ok
	end

	# GET /peer_assessments?submitted_for_id=2
	def index_with_submitted_for
	end

	# GET /peer_assessments?submitted_by_id=2
	def index_with_submitted_by
	end

	# GET /peer_assessments
	def index
		render json: format_errors({ base: ['There was no pa_form_id, submitted_by_id, or submitted_for_id in the params. Retry with one of those'] }), status: :forbidden
	end

	# GET /peer_assessments/:id
	def show
	end

	# POST /peer_assessments
	def create
	end


	private

    # The class of the resource that the controller handles
    def controller_resource
      PeerAssessment
    end

		def peer_assessments_params
			params.permit(:pa_form, :submitted_for_id, :submitted_by_id, :date_submitted, :answers)
		end
end
