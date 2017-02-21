class Includes::ProjectSerializer < ProjectSerializer
	belongs_to 	:assignment
	belongs_to 	:unit
	has_one			:lecturer

	has_many :students, serializer: Decorators::StudentMemberSerializer do
		object.student_members
	end
end
