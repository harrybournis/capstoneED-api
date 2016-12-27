class Includes::ProjectSerializer < ProjectSerializer
	belongs_to 	:assignment
	#has_many 		:students#, serializer: StudentWNicknameSerializer, options: { project_id: 2 }
	has_one			:lecturer

	has_many :students, serializer: Decorators::StudentMemberSerializer do
		object.student_members#.map { |student|  }
	end
end
