class V1::PeerAssessmentsController < ApplicationController

	before_action :allow_if_lecturer, only: [:index_with_pa_form, :index_with_submitted_for, :index_with_submitted_by, :index]
  before_action only: [:index_with_pa_form, :index_with_submitted_for, :index_with_submitted_by], if: 'params[:includes]' do
    validate_includes(current_user.peer_assessment_associations, includes_array, 'Peer Assessment')
  end
  before_action :set_peer_assessment_if_associated, only: [:show]


	# GET /peer_assessments?pa_form_id=2
	# Needs pa_form_id
	def index_with_pa_form
		@peer_assessments = current_user.peer_assessments(includes: includes_array).where(['pa_form_id = ?', params[:pa_form_id]])
		serialize_collection @peer_assessments, :ok
	end

	# GET /peer_assessments?pa_form_id=2&submitted_for_id=2
	# Needs pa_form_id AND submitted_by_for
	def index_with_submitted_for
		@peer_assessments = current_user.peer_assessments(includes: includes_array).where(['pa_form_id = ? and submitted_for_id = ?', params[:pa_form_id], params[:submitted_for_id]])
		serialize_collection @peer_assessments, :ok
	end

	# GET /peer_assessments?pa_form_id=2&submitted_by_id=2
	# Needs pa_form_id AND submitted_by_id
	def index_with_submitted_by
		@peer_assessments = current_user.peer_assessments(includes: includes_array).where(['pa_form_id = ? and submitted_by_id = ?', params[:pa_form_id], params[:submitted_by_id]])
		serialize_collection @peer_assessments, :ok
	end

	# GET /peer_assessments
	def index
		render json: format_errors({ base: ["There was no pa_form_id in the params. Try again with a pa_form_id in the params for all peer assessments for that PAForm, or with both a pa_form_id and a submitted_by_id or submitted_for_id for specific Student's peer assessments."] }), status: :bad_request
	end

	# GET /peer_assessments/:id
	def show
		serialize_object @peer_assessment, :ok
	end

	# POST /peer_assessments
	def create
	end


	private

    # Sets @peer_assessment if it is asociated with the current user. Eager loads associations in the params[:includes].
    # Renders error if not associated and Halts execution
    def set_peer_assessment_if_associated
      unless @peer_assessment = current_user.peer_assessments(includes: includes_array).where(id: params[:id])[0]
        render_not_associated_with_current_user('Peer Assessment')
        return false
      end
    end

    # The class of the resource that the controller handles
    def controller_resource
      PeerAssessment
    end

		def peer_assessments_params
			params.permit(:pa_form, :submitted_for_id, :submitted_by_id, :date_submitted, :answers)
		end
end
