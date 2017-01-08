class Includes::ProjectStudentSerializer < ProjectSerializer
	#attribute :nickname
	belongs_to 	:assignment
	has_one			:lecturer

	has_many :students, serializer: Decorators::StudentMemberSerializer do
		object.student_members
	end

  # def nickname
  # 	#current_user.nickname_for_project_id(object.id)
  # 	binding.pry
  # 	object.students_projects.each |sp|#.where(student_id: current_user.id)[0].nickname
  # 		sp.nickname ? sp.nickname : sp.student.full_name
  # 	end
  # end
end
