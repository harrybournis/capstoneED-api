# Holds the Gamification Settings for an Assignment
class GameSetting < ApplicationRecord
  # Attributes
  #
  # id :integer
  # assignment_id :integer
  # points_log :integer
  # points_log_first_of_day :integer
  # points_log_first_of_team :integer
  # points_log_first_of_assignment :integer
  # points_peer_assessment :integer
  # points_peer_assessment_first_of_team :integer
  # points_peer_assessment_first_of_assignment :integer
  # points_project_evaluation :integer
  # points_project_evaluation_first_of_team :integer
  # points_project_evaluation_first_of_assignment :integer
  # max_logs_per_day :integer

  belongs_to :assignment, inverse_of: :game_setting

  validates_presence_of :assignment
  validates :points_log,
            :points_log_first_of_day,
            :points_log_first_of_team,
            :points_log_first_of_assignment,
            :points_peer_assessment,
            :points_peer_assessment_first_of_team,
            :points_peer_assessment_first_of_assignment,
            :points_project_evaluation,
            :points_project_evaluation_first_of_team,
            :points_project_evaluation_first_of_assignment,
            :max_logs_per_day,
            presence: true, numericality: true

  before_validation :set_default_values

  # Default Points Values
  POINTS_LOG 																		= 50
  POINTS_LOG_FIRST_OF_DAY 											= 0
  POINTS_LOG_FIRST_OF_TEAM    									= 5
  POINTS_LOG_FIRST_OF_ASSIGNMENT 								= 15
  POINTS_PEER_ASSESSMENT 												= 50
  POINTS_PEER_ASSESSMENT_FIRST_OF_TEAM    			= 5
  POINTS_PEER_ASSESSMENT_FIRST_OF_ASSIGNMENT 		= 15
  POINTS_PROJECT_EVALUATION 										= 50
  POINTS_PROJECT_EVALUATION_FIRST_OF_TEAM    		= 5
  POINTS_PROJECT_EVALUATION_FIRST_OF_ASSIGNMENT = 15
  MAX_LOGS_PER_DAY                              = 3

  private

  # Sets the default value for any parameter not provided by the user
  def set_default_values
  	self.points_log ||= POINTS_LOG
    self.points_log_first_of_day ||= POINTS_LOG_FIRST_OF_DAY
    self.points_log_first_of_team ||= POINTS_LOG_FIRST_OF_TEAM
    self.points_log_first_of_assignment ||= POINTS_LOG_FIRST_OF_ASSIGNMENT
    self.points_peer_assessment ||= POINTS_PEER_ASSESSMENT
    self.points_peer_assessment_first_of_team ||= POINTS_PEER_ASSESSMENT_FIRST_OF_TEAM
    self.points_peer_assessment_first_of_assignment ||= POINTS_PEER_ASSESSMENT_FIRST_OF_ASSIGNMENT
    self.points_project_evaluation ||= POINTS_PROJECT_EVALUATION
    self.points_project_evaluation_first_of_team ||= POINTS_PROJECT_EVALUATION_FIRST_OF_TEAM
    self.points_project_evaluation_first_of_assignment ||= POINTS_PROJECT_EVALUATION_FIRST_OF_ASSIGNMENT
    self.max_logs_per_day ||= MAX_LOGS_PER_DAY
  end
end

    # points_log
    # points_log_first_of_day
    # points_log_first_of_team
    # points_log_first_of_assignment
    # points_peer_assessment
    # points_peer_assessment_first_of_team
    # points_peer_assessment_first_of_assignment
    # points_project_evaluation
    # points_project_evaluation_first_of_team
    # points_project_evaluation_first_of_assignment
    # max_logs_per_day
