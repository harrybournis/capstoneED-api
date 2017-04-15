## Peer Assessments Controller
class V1::PeerAssessmentsController < ApplicationController
  before_action :allow_if_student,  only: [:create]
  before_action :validate_includes,
                only: [:index, :show],
                if: 'params[:includes]'
  before_action :set_peer_assessment_if_associated, only: [:show]

  def index
    if query_params.empty?
      render json: format_errors({ base: ["There was no pa_form_id in the params. Try again with a pa_form_id in the params for all peer assessments for that PAForm, or with either a pa_form_id and a submitted_by_id or a pa_form_id and a submitted_for_id for specific Student's peer assessments."] }),
             status: :bad_request
      return
    end

    @peer_assessments = current_user.peer_assessments(includes: includes_array)
                                    .api_query(query_params)

    if current_user.type == 'Student'
      serialize_collection @peer_assessments, :ok, PeerAssessmentStudentSerializer
    else
      serialize_collection @peer_assessments, :ok
    end
  end

  # GET /peer_assessments/:id
  def show
    if current_user.type == 'Student'
      serialize_object @peer_assessment, :ok, PeerAssessmentStudentSerializer
    else
      serialize_object @peer_assessment, :ok
    end
  end

  # POST /peer_assessments
  def create
    if params[:peer_assessments] && multiple_params.permitted?
      @pa = []

      multiple_params[:peer_assessments].each do |param|
        pa = PeerAssessment.new param
        pa.submitted_by = current_user.load

        if pa.save && pa.submit
          @pa << pa
        else
          render json: format_errors(pa.errors),
                 status: :unprocessable_entity
          return
        end
      end

      @points_board = award_points :peer_assessment, @pa[0]
    else
      @pa = PeerAssessment.new(peer_assessment_params)
      @pa.submitted_by = current_user.load

      if @pa.save && @pa.submit # submit it
        @points_board = award_points :peer_assessment, @pa
      else
        render json: format_errors(@pa.errors),
               status: :unprocessable_entity
        return
      end
    end

    if @points_board.success?
      render json: serialize_w_points(@pa, @points_board),
             status: :created
    else
      render json: serialize_w_points(
                      @pa, @points_board),
             status: :created
    end
  end

  private

  # Sets @peer_assessment if it is asociated with the current user.
  # Eager loads associations in the params[:includes].
  # Renders error if not associated and Halts execution
  def set_peer_assessment_if_associated
    unless @peer_assessment = current_user.peer_assessments(includes: includes_array)
                                          .where(id: params[:id])[0]
      render_not_associated_with_current_user('Peer Assessment')
      return false
    end
  end

  # The class of the resource that the controller handles
  def controller_resource
    PeerAssessment
  end

  def peer_assessment_params
    params.permit(:pa_form_id, :submitted_for_id,
                  answers: [:question_id, :answer])
  end

  def multiple_params
    params.permit(peer_assessments: [:pa_form_id, :submitted_for_id,
                  answers: [:question_id, :answer]])
  end

  def query_params
    params.permit(:pa_form_id, :submitted_for_id, :submitted_by_id,
                  :iteration_id, :project_id)
  end
end
