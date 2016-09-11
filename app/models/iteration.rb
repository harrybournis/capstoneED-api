class Iteration < ApplicationRecord
	# Attributes: name(string), start_date(datetime), deadline(datetime), project_id(integer)

	# Associations
	belongs_to :project
	has_many :teams, through: :project
	has_many :students_teams, through: :teams

	# Validations
	validates_presence_of :name, :start_date, :deadline, :project_id
	validate :start_date_is_in_the_future
	validate :deadline_is_after_start_date


	private

		def start_date_is_in_the_future
			unless start_date.present? && start_date > DateTime.now
				errors.add(:start_date, "can't be in the past")
			end
		end

		def deadline_is_after_start_date
			unless deadline.present? && start_date.present? && deadline > start_date
				errors.add(:deadline, "can't be before the start_date")
			end
		end
end
