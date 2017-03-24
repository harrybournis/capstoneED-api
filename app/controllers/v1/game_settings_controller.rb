# Deals with creating and editing GameSettings
class V1::GameSettingsController < ApplicationController
  before_action :allow_if_lecturer
  before_action :set_assignment_if_associated

  # GET /assignments/:assignment_id/game_settings
  def index
    @assignment.game_setting.tap do |settings|
      if settings
        render json: settings, status: :ok
      else
        render json: "", status: :no_content
      end
    end
  end

  # POST /assignments/:assignment_id/game_settings
  def create
    if @assignment.game_setting
      message = ['This assignment already contains game setting. Try PATCH /assignments/:assignment_id/game_settings/:game_settings_id to update.']
      render json: format_errors(assignment_id: message), status: :forbidden
      return
    end

    game_setting = GameSetting.new(game_settings_params)

    if game_setting.save
      render json: game_setting, status: :created
    else
      render json: format_errors(game_setting.errors), status: 422
    end
  end

  # PATCH /assignments/:assignment_id/game_settings/:id
  def update
    if @assignment.game_setting
      game_setting = @assignment.game_setting
    else
      message = ["This assignment does not have game settings. First create them at POST /assignments/:assignment_id/game_settings"]
      render json: format_errors(base: message), status: :unprocessable_entity
      return
    end

    if game_setting.update(game_settings_params.except(:assignment_id))
      render json: game_setting, status: :ok
    else
      render json: format_errors(game_setting.errors), status: :unprocessable_entity
    end
  end

  private

  # Sets @assignment if it is asociated with the current user. Eager loads
  # associations in the params[:includes]. Renders error if not associated
  # and Halts execution.
  def set_assignment_if_associated
    unless @assignment = current_user.assignments
                                     .where(id: params[:assignment_id])[0]
      render_not_associated_with_current_user('Assignment')
      false
    end
  end

  def game_settings_params
    params.permit(:assignment_id,
                  :points_log,
                  :points_log_first_of_day,
                  :points_log_first_of_team,
                  :points_log_first_of_assignment,
                  :points_peer_assessment,
                  :points_peer_assessment_first_of_day,
                  :points_peer_assessment_first_of_team,
                  :points_peer_assessment_first_of_assignment,
                  :points_project_evaluation,
                  :points_project_evaluation_first_of_day,
                  :points_project_evaluation_first_of_team,
                  :points_project_evaluation_first_of_assignment)
  end
end
