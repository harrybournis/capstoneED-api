class Includes::PeerAssessmentStudentSerializer < PeerAssessmentStudentSerializer
	belongs_to :pa_form
	belongs_to :submitted_for
	belongs_to :submitted_by
end
