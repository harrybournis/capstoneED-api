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
    @question_text = FactoryGirl.create :question_type, category: 'text', friendly_name: 'Comment'
    @question_number = FactoryGirl.create :question_type, category: 'number', friendly_name: 'Linkert Scale'
    @question_rank = FactoryGirl.create :question_type, category: 'rank', friendly_name: 'Rank'

    points_object_values = [20,40,50,10,30, 20,40,50,10,30, 20,40,50,10,30]
    student_points = [50, 60, 10, 10, 20, 70, 80, 40, 30, 20, 40, 60, 50, 90, 40]
    hours_worked = [1,2,3,4,5,6,7,8,9,10]
    hours_worked_small = [1,2,3]
    hours_worked_medium = [3,4,5,6]
    hours_worked_large = [5,6,7,8,9,10]

    # Lecturer-units-assignments
    @lecturer = FactoryGirl.create :lecturer_confirmed, first_name: 'Thanos', last_name: 'Hatziapostolou', email: 'thanos@hatziapostolou.com', password: '12345678'
    @department = FactoryGirl.create :department, name: 'Computer Science', university: 'University of Sheffield'
    @unit1 = FactoryGirl.create :unit, lecturer: @lecturer, name: 'Web Programming', code: 'CCP2300', semester: 'Spring', year: 2017, department: @department
    @unit2 = FactoryGirl.create :unit, lecturer: @lecturer, name: 'Data Structures', code: 'CCP2400', semester: 'Spring', year: 2017, department: @department

    now = DateTime.now
    @assignment11 = FactoryGirl.create :assignment, lecturer: @lecturer, name: 'Practical 1', start_date: now - 2.month, end_date: now - 1.month - 1.day, unit: @unit1
    @assignment12 = FactoryGirl.create :assignment, lecturer: @lecturer, name: 'Practical 2', start_date: now - 1.month, end_date: now + 1.day, unit: @unit1

    @game_settings = GameSetting.new assignment_id: @assignment12.id
    @game_settings.save


    # @assignment21 = FactoryGirl.create :assignment, lecturer: @lecturer, name: 'Practical 1', start_date: now - 1.month, end_date: now - 1.day, unit: @unit2
    # @assignment22 = FactoryGirl.create :assignment, lecturer: @lecturer, name: 'Practical 2', start_date: now , end_date: now + 2.month, unit: @unit2
    #
    # Iterations
    # FactoryGirl.create :iteration, name: 'Analysis - Design', start_date: @assignment11.start_date, deadline: @assignment11.start_date + 15.days, assignment: @assignment11
    # FactoryGirl.create :iteration,  name: 'Implementation', start_date: @assignment11.start_date + 15.days, deadline: @assignment11.end_date, assignment: @assignment11

    @iteration121 = FactoryGirl.create :iteration,  name: 'Analysis', start_date: @assignment12.start_date, deadline: @assignment12.start_date + 10.days, assignment: @assignment12
    @iteration122 = FactoryGirl.create :iteration,  name: 'Design', start_date: @assignment12.start_date + 11.days, deadline: @assignment12.start_date + 20.days, assignment: @assignment12
    @iteration123 = FactoryGirl.create :iteration,  name: 'Implementation', start_date: @assignment12.start_date + 20.days, deadline: @assignment12.end_date, assignment: @assignment12

    # FactoryGirl.create :iteration,  name: 'Analysis - Design', start_date: @assignment21.start_date, deadline: @assignment21.start_date + 15.days, assignment: @assignment21
    # FactoryGirl.create :iteration,  name: 'Implementation', start_date: @assignment21.start_date + 15.days, deadline: @assignment21.end_date, assignment: @assignment21
    #
    # FactoryGirl.create :iteration,  name: 'Analysis', start_date: @assignment22.start_date, deadline: @assignment22.start_date + 20.days, assignment: @assignment22
    # FactoryGirl.create :iteration,  name: 'Design', start_date: @assignment22.start_date + 21.days, deadline: @assignment22.start_date + 30.days, assignment: @assignment22
    # FactoryGirl.create :iteration,  name: 'Implementation', start_date: @assignment22.start_date + 30.days, deadline: @assignment22.end_date, assignment: @assignment22
    #
    # Projects
    # @project = FactoryGirl.create :project, project_name: 'fish.gr Website', team_name: 'Fishermen', enrollment_key: 'key', assignment: @assignment11, unit: @assignment11.unit
    # @project = FactoryGirl.create :project, project_name: 'petshop.gr Website', team_name: 'Puppies', enrollment_key: 'key', assignment: @assignment11, unit: @assignment11.unit
    # @project = FactoryGirl.create :project, project_name: 'congress.com Website', team_name: 'CIA Agents', enrollment_key: 'key', assignment: @assignment11, unit: @assignment11.unit
    #
    @project1 = FactoryGirl.create :project, project_name: 'food.gr Website', team_name: 'FoodGr-ers', enrollment_key: 'key', assignment: @assignment12, unit: @assignment12.unit
    @project2 = FactoryGirl.create :project, project_name: 'books.gr Website', team_name: 'Book Team', enrollment_key: 'key', assignment: @assignment12, unit: @assignment12.unit
    @project3 = FactoryGirl.create :project, project_name: 'clothes.gr Website', team_name: 'The Fashion Police', enrollment_key: 'key', assignment: @assignment12, unit: @assignment12.unit
    @project4 = FactoryGirl.create :project, project_name: 'medieval-gear.gr Website', team_name: 'Knights of Frappe', enrollment_key: 'key', assignment: @assignment12, unit: @assignment12.unit


    # Pa Form
    questions = [{ 'text' => 'The team member completed an equal share of work', 'type_id' => @question_number.id },
                 { 'text' => 'The team member was extremely eager to plan and execute tasks and the project as a whole', 'type_id' => @question_number.id },
                 { 'text' => 'The team member took a leadership role organizing others, encouraging group participation supporting when necessary and solving problems', 'type_id' => @question_number.id },
                 { 'text' => 'The team member routinely uses time well throughout the project to ensure things get done on time and meet deadlines and responsibilities', 'type_id' => @question_number.id },
                 { 'text' => 'Rank your team members according to their overall contribution to the project', 'type_id' => @question_rank.id },
                 { 'text' => 'If you want, you can leave a comment about the teammbers', 'type_id' => @question_text.id }]
    @pa_form1 = FactoryGirl.create :pa_form, iteration_id: @iteration121.id, start_offset: 0, end_offset: 3.days.to_i, questions: questions
    @pa_form2 = FactoryGirl.create :pa_form, iteration_id: @iteration122.id, start_offset: 0, end_offset: 3.days.to_i, questions: questions
    @pa_form3 = FactoryGirl.create :pa_form, iteration_id: @iteration123.id, start_offset: 0, end_offset: 3.days.to_i, questions: questions


    # Lecturer project evaluations
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @lecturer.id, percent_complete: 6
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @lecturer.id, percent_complete: 20
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @lecturer.id, percent_complete: 35
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @lecturer.id, percent_complete: 40
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @lecturer.id, percent_complete: 60
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @lecturer.id, percent_complete: 80
    pe.save validate: false

    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project2.id, user_id: @lecturer.id, percent_complete: 10
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project2.id, user_id: @lecturer.id, percent_complete: 10
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project2.id, user_id: @lecturer.id, percent_complete: 20
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project2.id, user_id: @lecturer.id, percent_complete: 30
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project2.id, user_id: @lecturer.id, percent_complete: 40
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project2.id, user_id: @lecturer.id, percent_complete: 40
    pe.save validate: false

    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project3.id, user_id: @lecturer.id, percent_complete: 5
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project3.id, user_id: @lecturer.id, percent_complete: 10
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project3.id, user_id: @lecturer.id, percent_complete: 50
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project3.id, user_id: @lecturer.id, percent_complete: 60
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project3.id, user_id: @lecturer.id, percent_complete: 60
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project3.id, user_id: @lecturer.id, percent_complete: 60
    pe.save validate: false

    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project4.id, user_id: @lecturer.id, percent_complete: 0
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project4.id, user_id: @lecturer.id, percent_complete: 15
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project4.id, user_id: @lecturer.id, percent_complete: 30
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project4.id, user_id: @lecturer.id, percent_complete: 50
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project4.id, user_id: @lecturer.id, percent_complete: 60
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project4.id, user_id: @lecturer.id, percent_complete: 80
    pe.save validate: false


    # Students

    # ³³³³³³³³³³³³³³³³³³³³³³³³³³³³³ our team ³³³³³³³³³³³³³³³³³³³
    @student1 = FactoryGirl.create :student_confirmed, first_name: 'Ioannis', last_name: 'Boutsikas', email: 'ioannis@boutsikas.com'
    @sp = FactoryGirl.create :students_project_seeder, project: @project1, student: @student1, nickname: 'Zinadore'

    (@assignment12.start_date.to_datetime..now).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end

    @sp.update(points: 150)
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @student1.id, percent_complete: 14
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @student1.id, percent_complete: 26
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @student1.id, percent_complete: 26
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @student1.id, percent_complete: 40
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @student1.id, percent_complete: 64
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @student1.id, percent_complete: 95
    pe.save validate: false


    @student2 = FactoryGirl.create :student_confirmed, first_name: "Harris", last_name: 'Bournis', email: 'harris@bournis.com'
    @sp = FactoryGirl.create :students_project_seeder, project: @project1, student: @student2, nickname: 'Peer Assessment Gangsta (PAG)'

    (@assignment12.start_date.to_datetime..now).to_a.sample(18).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 75)
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @student2.id, percent_complete: 20
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @student2.id, percent_complete: 33
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @student2.id, percent_complete: 25
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @student2.id, percent_complete: 60
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @student2.id, percent_complete: 90
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @student2.id, percent_complete: 100
    pe.save validate: false


    @student3 = FactoryGirl.create :student_confirmed, first_name: "Panos", last_name: 'Kapsalas', email: 'panos@kapsalas.com'
    @sp = FactoryGirl.create :students_project_seeder, project: @project1, student: @student3, nickname: 'Spectacular Lolos'

    (@assignment12.start_date.to_datetime..now).to_a.sample(26).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 130)
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @student3.id, percent_complete: 5
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @student3.id, percent_complete: 30
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @student3.id, percent_complete: 70
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @student3.id, percent_complete: 50
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @student3.id, percent_complete: 80
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @student3.id, percent_complete: 96
    pe.save validate: false

    @student4 = FactoryGirl.create :student_confirmed, first_name: "Thanos", last_name: 'Doulgeris', email: 'thanos@doulgeris.com'
    @sp = FactoryGirl.create :students_project_seeder, project: @project1, student: @student4, nickname: 'Tyccoon Typhoon'

    (@assignment12.start_date.to_datetime..now).to_a.sample(5).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked_large.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 15)
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 20
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 50
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 10
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 20
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 90
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 70
    pe.save validate: false

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Very hard worker, I enjoyed working with him.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 3}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Nice person, wrote nice report.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Good programmer.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 3}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'I though he was my friend...'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Excelent web designer'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Contributed significantly in this Iteration.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Was not punctual in meetings.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Acted as the leader and organized us all.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Very hard worker, I enjoyed working with him.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 3}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Nice person, wrote nice report.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Good programmer.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 3}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'I though he was my friend...'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Excelent web designer'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Contributed significantly in this Iteration.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Was not punctual in meetings.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Acted as the leader and organized us all.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]


    # ³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³ Team 2 ³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³
    # WORST TEAM
    @student1 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project2, student: @student1, nickname: 'SlimEliteHannah'

    (@assignment12.start_date.to_datetime..now).to_a.sample(3).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked_large.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 15)
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project2.id, user_id: @student1.id, percent_complete: 15
    # pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project2.id, user_id: @student1.id, percent_complete: 20
    pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project2.id, user_id: @student1.id, percent_complete: 80
    # pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project2.id, user_id: @student1.id, percent_complete: 90
    pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project2.id, user_id: @student1.id, percent_complete: 70
    # pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project2.id, user_id: @student1.id, percent_complete: 30
    pe.save validate: false


    @student2 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project2, student: @student2, nickname: 'Crampsal'

    (@assignment12.start_date.to_datetime..now).to_a.sample(10).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked_small.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 50)
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project2.id, user_id: @student2.id, percent_complete: 87
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project2.id, user_id: @student2.id, percent_complete: 64
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project2.id, user_id: @student2.id, percent_complete: 32
    # pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project2.id, user_id: @student2.id, percent_complete: 48
    pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project2.id, user_id: @student2.id, percent_complete: 90
    # pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project2.id, user_id: @student2.id, percent_complete: 95
    pe.save validate: false


    @student3 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project2, student: @student3, nickname: 'DarkSuru'
    @sp.update(points: 0)
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project2.id, user_id: @student3.id, percent_complete: 14
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project2.id, user_id: @student3.id, percent_complete: 26
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project2.id, user_id: @student3.id, percent_complete: 26
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project2.id, user_id: @student3.id, percent_complete: 40
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project2.id, user_id: @student3.id, percent_complete: 64
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project2.id, user_id: @student3.id, percent_complete: 95
    # pe.save validate: false


    # (@assignment12.start_date.to_datetime..now).to_a.sample(0).sort.each do |date|
    #   @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
    #   @sp.save
    # end

    @student4 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project2, student: @student4, nickname: 'OneTrendy'
    @sp.update(points: 0)
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 14
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 26
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 26
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 40
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 64
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project1.id, user_id: @student4.id, percent_complete: 95
    # pe.save validate: false

    # (@assignment12.start_date.to_datetime..now).to_a.sample(0).sort.each do |date|
    #   @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
    #   @sp.save
    # end

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]

    # FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    # FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]
    # FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    # FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]


    # ³³³³³³³³³³³³³³³³³³³³³³³³³³³ Team 3 ³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³
    # BEST TEAM
    @student1 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project3, student: @student1, nickname: 'HeroBiggRodeo'

    (@assignment12.start_date.to_datetime..now).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 150)
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project3.id, user_id: @student1.id, percent_complete: 14
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project3.id, user_id: @student1.id, percent_complete: 26
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project3.id, user_id: @student1.id, percent_complete: 26
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project3.id, user_id: @student1.id, percent_complete: 40
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project3.id, user_id: @student1.id, percent_complete: 64
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project3.id, user_id: @student1.id, percent_complete: 95
    pe.save validate: false


    @student2 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project3, student: @student2, nickname: 'Slimodocam'

    (@assignment12.start_date.to_datetime..now).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 150)
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project3.id, user_id: @student2.id, percent_complete: 5
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project3.id, user_id: @student2.id, percent_complete: 16
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project3.id, user_id: @student2.id, percent_complete: 36
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project3.id, user_id: @student2.id, percent_complete: 60
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project3.id, user_id: @student2.id, percent_complete: 76
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project3.id, user_id: @student2.id, percent_complete: 90
    pe.save validate: false


    @student3 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project3, student: @student3, nickname: 'Jamentoity'

    (@assignment12.start_date.to_datetime..now).to_a.sample(29).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 145)
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project3.id, user_id: @student3.id, percent_complete: 12
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project3.id, user_id: @student3.id, percent_complete: 29
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project3.id, user_id: @student3.id, percent_complete: 64
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project3.id, user_id: @student3.id, percent_complete: 60
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project3.id, user_id: @student3.id, percent_complete: 80
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project3.id, user_id: @student3.id, percent_complete: 100
    pe.save validate: false


    @student4 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project3, student: @student4, nickname: 'Hoteliana'

    (@assignment12.start_date.to_datetime..now).to_a.sample(25).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 125)
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project3.id, user_id: @student4.id, percent_complete: 2
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project3.id, user_id: @student4.id, percent_complete: 23
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project3.id, user_id: @student4.id, percent_complete: 68
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project3.id, user_id: @student4.id, percent_complete: 79
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project3.id, user_id: @student4.id, percent_complete: 89
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project3.id, user_id: @student4.id, percent_complete: 100
    pe.save validate: false


    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Very hard worker, I enjoyed working with him.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Nice person, wrote nice report.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Good programmer.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'I though he was my friend...'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Excelent web designer'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Contributed significantly in this Iteration.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Was not punctual in meetings.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Acted as the leader and organized us all.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Very hard worker, I enjoyed working with him.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Nice person, wrote nice report.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Good programmer.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'I though he was my friend...'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Excelent web designer'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Contributed significantly in this Iteration.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Was not punctual in meetings.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Acted as the leader and organized us all.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]



    #³³³³³³³³³³³³³³³³³³³³³³³³³³³³ Team 4 ³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³
    @student1 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project4, student: @student1, nickname: 'Footbox'

    (@assignment12.start_date.to_datetime..now).to_a.sample(25).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked_medium.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 125)
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project4.id, user_id: @student1.id, percent_complete: 23
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project4.id, user_id: @student1.id, percent_complete: 32
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project4.id, user_id: @student1.id, percent_complete: 45
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project4.id, user_id: @student1.id, percent_complete: 50
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project4.id, user_id: @student1.id, percent_complete: 60
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project4.id, user_id: @student1.id, percent_complete: 74
    pe.save validate: false


    @student2 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project4, student: @student2, nickname: 'Skilled Salamander'

    (@assignment12.start_date.to_datetime..now).to_a.sample(14).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked_medium.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 70)
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project4.id, user_id: @student2.id, percent_complete: 14
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project4.id, user_id: @student2.id, percent_complete: 26
    # pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project4.id, user_id: @student2.id, percent_complete: 33
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project4.id, user_id: @student2.id, percent_complete: 86
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project4.id, user_id: @student2.id, percent_complete: 85
    pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project4.id, user_id: @student2.id, percent_complete: 78
    pe.save validate: false


    @student3 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project4, student: @student3, nickname: 'Sunny King'
    @sp.update(points: 0)
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project4.id, user_id: @student3.id, percent_complete: 14
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project4.id, user_id: @student3.id, percent_complete: 26
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project4.id, user_id: @student3.id, percent_complete: 26
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project4.id, user_id: @student3.id, percent_complete: 40
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project4.id, user_id: @student3.id, percent_complete: 64
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project4.id, user_id: @student3.id, percent_complete: 95
    # pe.save validate: false


    # (@assignment12.start_date.to_datetime..now).to_a.sample(0).sort.each do |date|
    #   @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
    #   @sp.save
    # end

    @student4 = FactoryGirl.create :student_confirmed_seeder
    @sp = FactoryGirl.create :students_project_seeder, project: @project4, student: @student4, nickname: 'Panther Colonel'

    (@assignment12.start_date.to_datetime..now).to_a.sample(9).sort.each do |date|
      @sp.add_log(JSON.parse({ date_worked: date.to_i.to_s, time_worked: hours_worked_large.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json), date.to_i.to_s)
      @sp.save
    end
    @sp.update(points: 45)
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 5.days - 2.hours, iteration_id: @iteration121.id, project_id: @project4.id, user_id: @student4.id, percent_complete: 14
    # pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 10.days - 2.hours, iteration_id: @iteration121.id, project_id: @project4.id, user_id: @student4.id, percent_complete: 63
    pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 15.days - 2.hours, iteration_id: @iteration122.id, project_id: @project4.id, user_id: @student4.id, percent_complete: 26
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 20.days - 2.hours, iteration_id: @iteration122.id, project_id: @project4.id, user_id: @student4.id, percent_complete: 40
    # pe.save validate: false
    # pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.start_date + 25.days - 2.hours, iteration_id: @iteration123.id, project_id: @project4.id, user_id: @student4.id, percent_complete: 64
    # pe.save validate: false
    pe = FactoryGirl.build :project_evaluation, date_submitted: @assignment12.end_date - 2.hours, iteration_id: @iteration123.id, project_id: @project4.id, user_id: @student4.id, percent_complete: 86
    pe.save validate: false

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 3}, {'question_id' => 2, 'answer' => 2}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 1}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Very hard worker, I enjoyed working with him.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student1, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 2}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 2}, {'question_id' => 4, 'answer' => 3}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Nice person, wrote nice report.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Good programmer.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student2, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 3}, {'question_id' => 2, 'answer' => 3}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 1}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'I though he was my friend...'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Excelent web designer'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student3, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 3}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student1, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 2}, {'question_id' => 3, 'answer' => 2}, {'question_id' => 4, 'answer' => 2}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Contributed significantly in this Iteration.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student2, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Was not punctual in meetings.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student3, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Acted as the leader and organized us all.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form1, submitted_by: @student4, submitted_for: @student4, date_submitted: @iteration121.deadline + 1.hour, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 2}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 1}, {'question_id' => 2, 'answer' => 3}, {'question_id' => 3, 'answer' => 2}, {'question_id' => 4, 'answer' => 2}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Very hard worker, I enjoyed working with him.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student1, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 2}, {'question_id' => 2, 'answer' => 1}, {'question_id' => 3, 'answer' => 2}, {'question_id' => 4, 'answer' => 3}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Nice person, wrote nice report.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 3}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Good programmer.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student2, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 3}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 2}, {'question_id' => 4, 'answer' => 3}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'I though he was my friend...'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 3}, {'question_id' => 6, 'answer' => 'Excelent web designer'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => ''}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student3, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 5}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 4}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => 'Could improve in being good.'}]

    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student1, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 3}, {'question_id' => 2, 'answer' => 3}, {'question_id' => 3, 'answer' => 3}, {'question_id' => 4, 'answer' => 3}, {'question_id' => 5, 'answer' => 2}, {'question_id' => 6, 'answer' => 'Contributed significantly in this Iteration.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student2, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 3}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 3}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Was not punctual in meetings.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student3, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 4}, {'question_id' => 4, 'answer' => 2}, {'question_id' => 5, 'answer' => 4}, {'question_id' => 6, 'answer' => 'Acted as the leader and organized us all.'}]
    FactoryGirl.create :peer_assessment, pa_form: @pa_form2, submitted_by: @student4, submitted_for: @student4, date_submitted: @iteration122.deadline + 1.hours,answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}, {'question_id' => 3, 'answer' => 5}, {'question_id' => 4, 'answer' => 5}, {'question_id' => 5, 'answer' => 5}, {'question_id' => 6, 'answer' => ''}]

    # Form Templates
    FactoryGirl.create :form_template, lecturer_id: @lecturer.id, name: 'Industial Project template', questions: questions
    FactoryGirl.create :form_template, lecturer_id: @lecturer.id, name: 'My simple template', questions: questions
    FactoryGirl.create :form_template, lecturer_id: @lecturer.id, name: 'Template 1', questions: questions

    # Lecturer Questions
    FactoryGirl.create :question, lecturer_id: @lecturer.id, question_type_id: @question_text.id, text: 'If you want, you can leave a comment about the teammbers'
    FactoryGirl.create :question, lecturer_id: @lecturer.id, question_type_id: @question_number.id, text: 'The team member completed an equal share of work'
    FactoryGirl.create :question, lecturer_id: @lecturer.id, question_type_id: @question_number.id, text: 'The team member was extremely eager to plan and execute tasks and the project as a whole'
    FactoryGirl.create :question, lecturer_id: @lecturer.id, question_type_id: @question_number.id, text: 'The team member took a leadership role organizing others, encouraging group participation supporting when necessary and solving problems'
    FactoryGirl.create :question, lecturer_id: @lecturer.id, question_type_id: @question_number.id, text: 'The team member routinely uses time well throughout the project to ensure things get done on time and meet deadlines and responsibilities'
    FactoryGirl.create :question, lecturer_id: @lecturer.id, question_type_id: @question_rank.id, text: 'Rank your team members according to their overall contribution to the project'

