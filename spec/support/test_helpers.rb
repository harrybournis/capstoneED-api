module TestHelpers

  def parse_body
    JSON.parse(response.body)
  end

  def errors
    JSON.parse(response.body)['errors']
  end

  def errors_base
    JSON.parse(response.body)['errors']['base']
  end

  def status
    response.status
  end

  def body
    JSON.parse(response.body)
  end

  def sign_in(user)
    post '/v1/sign_in', params: { email: user.email, password: '12345678' }
    expect(status).to eq 200

    JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
  end

  def get_lecturer_with_units_assignments_projects
    @lecturer = FactoryBot.build(:lecturer_with_password).process_new_record
    @lecturer.save
    @lecturer.confirm
    2.times { @lecturer.units << FactoryBot.build(:unit, lecturer: @lecturer) }
    @lecturer.units.each { |unit| unit.assignments << Array.new(2){ FactoryBot.build(:assignment, lecturer: @lecturer) } }
    @lecturer.assignments.each { |assignment| assignment.projects << Array.new(3){ FactoryBot.build(:project) } }
    return @lecturer
  end

  def login_integration(student = nil)
    student = create :student_confirmed unless student
    post '/v1/sign_in', params: { email: student.email, password: '12345678' }
    expect(response.status).to eq(200)
    csrf = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
    return student, csrf
  end

  def pa_answers
    answers { [{ question_id: 1, answer: 2 }, { question_id: 2, answer: 4 }, { question_id: 3, answer: 3 }, { question_id: 4, answer: 3 }, { question_id: 5, answer: 5 }, { question_id: 6, answer: 'text stuff' }] }
  end

  def pa_answers2
    answers { [{ question_id: 1, answer: 2 }, { question_id: 2, answer: 4 }, { question_id: 3, answer: 3 }, { question_id: 4, answer: 3 }, { question_id: 5, answer: 5 }, { question_id: 6, answer: 'text stuff' }] }
  end

  def valid_log_entry
    JSON.parse({ date_worked: (DateTime.now - 1.day).to_i.to_s, date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json)
  end

  def invalid_log_entry
    JSON.parse({ date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json)
  end

  def valid_questions
      qs = ['What do you typically have for breakfast?',
            'Can you solve sudoko puzzles?',
            'Have you ever been professionally photographed?',
            'What do you like on your toast?',
            'Do you prefer green or red grapes?',
            'Can you play poker?',
            'What do you think the greatest invention has been?',
            'What horror fiction character scares you the most?',
            'At what age did you twig onto the fact Santa wasnt real?',
            'What are cooler? Dinosaurs or Dragons?',
            'Have you ever been in a helicopter?',
            'Have you ever been attacked by a wild animal?',
            'Whats your favourite precious stone?',
            'Do you collect anything?',
            'Could you ever hand milk a cow?',
            'Have you ever tossed your own pancake?',
            "Have you ever been approached by someone who knew you but you couldn't remember them for the life of you?",
            'If you were to join an emergency service which would it be?',
            'What historical period would you like to live in if you could go back in time?',
            'If you were a fashion designer, what style of clothing or accessories would you design?',
            'If you had friends round what DVDs would you have to watch?',
            'Do you prefer Honey or Jam?',
            "Whats your favourite alcoholic drink beginning with the letter V?",
            'If you were a member of the spice girls, what would your spice handle be?',
            'Have you ever owned a slinky?'
          ].sample(5)
        if QuestionType.all.any?
            type = QuestionType.all.sample
        else
            type = create :question_type
        end
      [].tap do |array|
        qs.each { |q| array << { 'text' => q, 'type_id' => type.id } }
      end
  end

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
end
