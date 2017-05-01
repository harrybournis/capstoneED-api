def valid_feelings_params
  if Feeling.all.count > 2
    feeling1 = Feeling.first
    feeling2 = Feeling.second
  else
    feeling1 = create :feeling
    feeling2 = create :feeling
  end
  [
    { feeling_id: feeling1.id, percent: 32 },
    { feeling_id: feeling2.id, percent: 64 }
  ]
end
### -----------------------
# Defaults
### -----------------------
# Default Feelings
feeling1 = Feeling.create(name: 'Happiness', value: 1)
feeling2 = Feeling.create(name: 'Love', value: 1)
feeling3 = Feeling.create(name: 'Relief', value: 1)
feeling4 = Feeling.create(name: 'Satisfaction', value: 1)
feeling5 = Feeling.create(name: 'Fear', value: -1)
feeling6 = Feeling.create(name: 'Disapointment', value: -1)
feeling7 = Feeling.create(name: 'Fears Confirmed', value: -1)
feeling8 = Feeling.create(name: 'Anger', value: -1)

# Default question types
FactoryGirl.create :question_type, category: 'text', friendly_name: 'Text'
FactoryGirl.create :question_type, category: 'number', friendly_name: 'Number'
FactoryGirl.create :question_type, category: 'rank', friendly_name: 'Rank'

points_object_values = [20,40,50,10,30, 20,40,50,10,30, 20,40,50,10,30]
student_points = [50, 60, 10, 10, 20, 70, 80, 40, 30, 20, 40, 60, 50, 90, 40]
hours_worked = [1,2,3,4,5,6,7,8,9,10]

### -----------------------
# Dummy Data
### -----------------------
# 1st Lecturer
department = FactoryGirl.create(:department_seeder, name: 'Computer Science')
department2 = FactoryGirl.create(:department_seeder, name: 'English Studies')

@lecturer1 = FactoryGirl.create(:lecturer_confirmed_seeder, email: 'kostas@bar.com')
@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
now = DateTime.now
@assignment = FactoryGirl.create(:assignment, lecturer: @lecturer1, unit: @unit1, start_date: now - 2.months, end_date: now + 2.months)
4.times { FactoryGirl.create(:project_seeder, assignment: @assignment) }
@iteration1 = FactoryGirl.create(:iteration, assignment: @assignment, start_date: @assignment.start_date, deadline: @assignment.start_date + 2.months - 1.hour)
@iteration2 = FactoryGirl.create(:iteration, assignment: @assignment, start_date: @assignment.start_date + 2.months - 1.hour, deadline: @assignment.start_date + 3.month)
@iteration3 = FactoryGirl.create(:iteration, assignment: @assignment, start_date: @assignment.start_date + 3.months + 1.day, deadline: @assignment.start_date + 4.months)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration1, start_offset: 2.seconds, end_offset: 1.month)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration2)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration3)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id, question_type: QuestionType.all.sample)

4.times do |i|
  5.times do
    @student = FactoryGirl.create(:student_confirmed_seeder)
    @student.confirm

    points = points_object_values.sample(rand(1..6))
    # point_object_array = []
    # points.each do |p|
    #   symbol = [:log_point, :peer_assessment_point, :project_evaluation_point].sample
    #   point_object_array << create(symbol, points: p, student_id: @student.id, project: @assignment.projects[i])
    # end

    sp = FactoryGirl.create :students_project_seeder, student: @student,
                                                  project: @assignment.projects[i],
                                                  points: points.sum
    10.times do |i|
      sp.add_log(JSON.parse({ date_worked: (DateTime.now + i.day).to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
      sp.save(validate: false)
    end
  end
end

stu = @assignment.projects[0].students[0]
stu.skip_confirmation_notification!
stu.update(email: 'giorgos@bar.com')
stu.confirm

Timecop.freeze @iteration1.deadline - 1.hour do
  @assignment.projects.each do |project|
    project.students.each do |student|
      pe = FactoryGirl.build(:project_evaluation_seeder, user: student, project: project, iteration: @iteration1, feelings_project_evaluations_attributes: valid_feelings_params)
      pe.save #validate: false
    end
  end
end

Timecop.travel @iteration1.start_date + 1.month - 5.hours do
  @assignment.projects.each do |project|
    project.students.each do |student|
      pe = FactoryGirl.build(:project_evaluation_seeder, user: student, project: project, iteration: @iteration1, feelings_project_evaluations_attributes: valid_feelings_params)
      pe.save #validate: false
    end
  end
end

Timecop.freeze @iteration1.deadline - 1.hour do
  @assignment.projects.each do |project|
    pe = FactoryGirl.build(:project_evaluation_seeder, user: @lecturer1, project: project, iteration: @iteration1,  feelings_project_evaluations_attributes: valid_feelings_params)
    pe.save #validate: false
  end
end

Timecop.travel @iteration1.start_date + 1.month - 5.hours do
  @assignment.projects.each do |project|
    pe = FactoryGirl.build(:project_evaluation_seeder, user: @lecturer1, project: project, iteration: @iteration1,  feelings_project_evaluations_attributes: valid_feelings_params)
    pe.save #validate: false
  end
end

# 2nd Lecturer
@lecturer2 = FactoryGirl.create(:lecturer_confirmed_seeder, email: 'foo1@bar.com')
@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
@assignment = FactoryGirl.create(:assignment, lecturer: @lecturer2, unit: @unit1, start_date: now - 2.months, end_date: now + 2.months)
4.times { FactoryGirl.create(:project_seeder, assignment: @assignment) }
@iteration1 = FactoryGirl.create(:iteration, assignment: @assignment, start_date: @assignment.start_date, deadline: @assignment.start_date + 2.months - 1.hour)
@iteration2 = FactoryGirl.create(:iteration, assignment: @assignment, start_date: @assignment.start_date + 2.months - 1.hour, deadline: @assignment.start_date + 3.month)
@iteration3 = FactoryGirl.create(:iteration, assignment: @assignment, start_date: @assignment.start_date + 3.months + 1.day, deadline: @assignment.start_date + 4.months)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration1, start_offset: 2.seconds, end_offset: 1.month)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration2)
FactoryGirl.create(:pa_form_seeder, iteration: @iteration3)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id, question_type: QuestionType.all.sample)
FactoryGirl.create(:question, lecturer_id: @lecturer2.id, question_type: QuestionType.all.sample)

4.times do |i|
  5.times do
    @student = FactoryGirl.create(:student_confirmed_seeder)
    @student.confirm

    #@assignment.projects[i].students << @student
    FactoryGirl.create :students_project_seeder, student: @student,
                                                 project: @assignment.projects[i],
                                                 points: student_points.sample
  end
end

Timecop.freeze now do
  @assignment.projects.each do |project|
    project.students.each do |student|
      pe = FactoryGirl.build(:project_evaluation_seeder, user: student, project: project, iteration: @iteration1, date_submitted: now, feelings_project_evaluations_attributes: valid_feelings_params)
      pe.save validate: false
    end
  end
end

Timecop.freeze now do
  @assignment.projects.each do |project|
    pe = FactoryGirl.build(:project_evaluation_seeder, user: @lecturer2, project: project, iteration: @iteration1, date_submitted: now, feelings_project_evaluations_attributes: valid_feelings_params)
    pe.save validate: false
  end
end
