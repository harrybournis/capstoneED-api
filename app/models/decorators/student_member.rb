class Decorators::StudentMember

	include ActiveModel::Serialization

	def initialize(student, students_project)
		@student = student
		@id = student.id
		@first_name = student.first_name
		@last_name = student.last_name
		@email = student.email
		@provider = student.provider
		@type = "Student"
		@avatar_url = student.avatar_url
		@nickname = students_project.nickname if students_project.nickname
	end

	attr_accessor :id, :first_name, :last_name, :email, :provider, :type, :nickname, :avatar_url
end
