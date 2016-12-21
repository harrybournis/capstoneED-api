module Project::Enrollable

	extend ActiveSupport::Concern

  # Add a student to a Team with validations
  def enrol(student)
  	enrolment = JoinTables::StudentsProject.new(project: self, student: student)

  	if enrolment.save
  		true
  	else
			enrolment.errors.full_messages.each { |error| errors[:base] << error }
			false
		end
  end


  private

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
end
