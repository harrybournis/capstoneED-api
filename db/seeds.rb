FactoryGirl.create :question_type, category: 'text', friendly_name: 'Text'
FactoryGirl.create :question_type, category: 'number', friendly_name: 'Number'
FactoryGirl.create :question_type, category: 'rank', friendly_name: 'Rank'

# 1st Lecturer
department = FactoryGirl.create(:department_seeder, name: 'Computer Science')
department2 = FactoryGirl.create(:department_seeder, name: 'English Studies')

@lecturer1 = FactoryGirl.create(:lecturer_confirmed_seeder, email: 'kostas@bar.com')
@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
now = DateTime.now
@assignment = FactoryGirl.create(:assignment, lecturer: @lecturer1, unit: @unit1)
4.times { FactoryGirl.create(:project_seeder, assignment: @assignment) }
@iteration1 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now - 40.seconds, deadline: now + 5.second)
@iteration2 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 11.seconds, deadline: now + 1.month)
@iteration3 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 1.month, deadline: now + 2.months)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration1, start_offset: 2.seconds, end_offset: 1.month)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration2)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration3)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)

4.times do |i|
  5.times do
    @student = FactoryGirl.create(:student_confirmed_seeder)
    @student.confirm

    #@assignment.projects[i].students << @student
    FactoryGirl.create :students_project_seeder, student: @student, project: @assignment.projects[i]
  end
end

stu = @assignment.projects[0].students[0]
stu.skip_confirmation_notification!
stu.update(email: 'giorgos@bar.com')
stu.confirm

Timecop.freeze now do
  @assignment.projects.each do |project|
    project.students.each do |student|
      FactoryGirl.create(:project_evaluation_seeder, user: student, project: project, iteration: @iteration1, date_submitted: now)
    end
  end
end

Timecop.freeze now do
  @assignment.projects.each do |project|
    FactoryGirl.create(:project_evaluation_seeder, user: @lecturer1, project: project, iteration: @iteration1, date_submitted: now)
  end
end



# 2nd Lecturer
@lecturer2 = FactoryGirl.create(:lecturer_confirmed_seeder, email: 'foo1@bar.com')
@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
@assignment = FactoryGirl.create(:assignment, lecturer: @lecturer2, unit: @unit1)
4.times { FactoryGirl.create(:project_seeder, assignment: @assignment) }
@iteration1 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now - 40.seconds, deadline: now + 1.second)
@iteration2 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 11.seconds, deadline: now + 1.month)
@iteration3 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 1.month, deadline: now + 2.months)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration1, start_offset: 2.seconds, end_offset: 1.month)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration2)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration3)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id)

4.times do |i|
  5.times do
    @student = FactoryGirl.create(:student_confirmed_seeder)
    @student.confirm

    #@assignment.projects[i].students << @student
    FactoryGirl.create :students_project_seeder, student: @student, project: @assignment.projects[i]
  end
end

Timecop.freeze now do
  @assignment.projects.each do |project|
    project.students.each do |student|
      FactoryGirl.create(:project_evaluation_seeder, user: student, project: project, iteration: @iteration1, date_submitted: now)
    end
  end
end

Timecop.freeze now do
  @assignment.projects.each do |project|
    FactoryGirl.create(:project_evaluation_seeder, user: @lecturer2, project: project, iteration: @iteration1, date_submitted: now)
  end
end
