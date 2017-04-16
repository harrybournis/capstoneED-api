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
    @lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
    @lecturer.save
    @lecturer.confirm
    2.times { @lecturer.units << FactoryGirl.build(:unit, lecturer: @lecturer) }
    @lecturer.units.each { |unit| unit.assignments << Array.new(2){ FactoryGirl.build(:assignment, lecturer: @lecturer) } }
    @lecturer.assignments.each { |assignment| assignment.projects << Array.new(3){ FactoryGirl.build(:project) } }
    return @lecturer
  end

  def login_integration(student = nil)
    student = create :student_confirmed unless student
    post '/v1/sign_in', params: { email: student.email, password: '12345678' }
    expect(response.status).to eq(200)
    csrf = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']
    return student, csrf
  end

  def valid_log_entry
    JSON.parse({ date_worked: (DateTime.now - 1.day).to_i.to_s, date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json)
  end

  def invalid_log_entry
    JSON.parse({ date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json)
  end

end
