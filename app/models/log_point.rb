# Historical Data for all points gained through submitting logs.
class LogPoint < ApplicationRecord
  # Attributes
  # points :integer
  # reason_id :integer
  # log_id :integer
  # project_id :integer
  # date :datetime
  # students_project_id :integer

  belongs_to :project
  belongs_to :students_project, class_name: JoinTables::StudentsProject

  validates_presence_of :points, :date, :project_id, :students_project_id
end
