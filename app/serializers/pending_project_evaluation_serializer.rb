class PendingProjectEvaluationSerializer < ActiveModel::Serializer
  attributes :project_id, :iteration_id
  attribute :team_answers, if: :lecturer?

  def lecturer?
    current_user.lecturer?
  end

  type 'pending_evaluations'
end
