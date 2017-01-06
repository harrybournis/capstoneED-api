module Project::Enrollable

	extend ActiveSupport::Concern

  # Add a student to a Team with validations
  def enrol(student, nickname = nil)
  	enrolment = JoinTables::StudentsProject.new(project: self, student: student, nickname: nickname)

  	if enrolment.save
  		true
  	else
			enrolment.errors.full_messages.each { |error| errors[:base] << error }
			false
		end
  end


  private

    # Generates enrolment key if it has not been given
    def generate_enrollment_key
      unless enrollment_key.present?
        generated_key = nil
        loop do
          generated_key = SecureRandom.base64(32)
          break unless Project.where(enrollment_key: generated_key).any?
        end
        self.enrollment_key = generated_key
      end
    end

    # generates a team_name if it has not been given and it is a new record.
    # Counts the number of projects in the Assignment and advances the number by 1
    # in the team_name
    def generate_team_name
      if !team_name && !persisted?
        self.team_name = "Team #{assignment.project_counter + 1}"
        assignment.project_counter += 1
      end
    end
end
