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

  def get_lecturer_with_units_assignments_projects
    @lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
    @lecturer.save
    @lecturer.confirm
    2.times { @lecturer.units << FactoryGirl.build(:unit, lecturer: @lecturer) }
    @lecturer.units.each { |unit| unit.assignments << Array.new(2){ FactoryGirl.build(:assignment, lecturer: @lecturer) } }
    @lecturer.assignments.each { |assignment| assignment.projects << Array.new(3){ FactoryGirl.build(:project) } }
    return @lecturer
  end

end
