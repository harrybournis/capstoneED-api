# Module for decorator classes.
module Decorators
  # Decorates the Student with their nickname for a Specific Project
  class StudentMember
    include ActiveModel::Serialization

    def initialize(student, students_project)
      @student = student
      @id = student.id
      @first_name = student.first_name
      @last_name = student.last_name
      @email = student.email
      @provider = student.provider
      @type = 'Student'
      @avatar_url = student.avatar_url
      @nickname = students_project.nickname if students_project.nickname
      @points = students_project.points     if students_project.points
    end

    attr_accessor :id, :first_name, :last_name, :email, :provider, :type,
                  :avatar_url, :nickname, :points
  end
end
