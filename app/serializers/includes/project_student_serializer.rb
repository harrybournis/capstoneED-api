class Includes::ProjectStudentSerializer < ProjectStudentSerializer
	belongs_to 	:assignment
	has_one			:lecturer

	has_many :students, serializer: Decorators::StudentMemberSerializer do
		object.reload
		object.student_members
	end
end
