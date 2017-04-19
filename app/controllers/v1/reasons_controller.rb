# Deals with the reasons for awarding points to students.
#
class V1::ReasonsController < ApplicationController
  # GET /v1/reasons
  # Returns the reasons.yml file in JSON form.
  def index
    render json: Reason.to_json, status: :ok
  end
end
