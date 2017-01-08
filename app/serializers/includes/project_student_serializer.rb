class Includes::ProjectStudentSerializer < ProjectSerializer
	attribute :nickname
	belongs_to 	:assignment
	has_one			:lecturer

	has_many :students, serializer: Decorators::StudentMemberSerializer do
		object.student_members
	end

  def nickname
  	current_user.nickname_for_project_id(object.id)
  end
end
