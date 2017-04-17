require 'rails_helper'

RSpec.describe  StudentsProject, type: :model do

	subject { FactoryGirl.build :students_project }

	it { should belong_to :project }
	it { should belong_to :student }

	it 'works' do
		expect(FactoryGirl.create(:students_project)).to be_truthy
	end

	it 'should validate that the student is not already part of the Project in a different team' do
		student = FactoryGirl.create(:student)
		assignment = FactoryGirl.create(:assignment_with_projects)
		create :students_project, student: student, project: assignment.projects[0]

		students_project =  StudentsProject.new(student_id: student.id, project_id: assignment.projects.last.id)
		expect(students_project.valid?).to be_falsy
		expect(students_project.errors[:student_id].first).to eq('has already enroled in a different Project for this Assignment')
	end

	it 'validates uniqueness of nickname for project' do
		student = FactoryGirl.create(:student)
		student_other = FactoryGirl.create(:student)
		student_third = FactoryGirl.create(:student)
		assignment = FactoryGirl.create(:assignment_with_projects)
		project = assignment.projects.first
		project_other = assignment.projects.last

		sp1 =  StudentsProject.new(nickname: 'methodman', student_id: student.id, project_id: project.id)
		sp2 =  StudentsProject.new(nickname: 'methodman', student_id: student_other.id, project_id: project.id)
		sp3 =  StudentsProject.new(nickname: 'methodman', student_id: student_other.id, project_id: project_other.id)
		sp4 =  StudentsProject.new(nickname: 'methodman', student_id: student_third.id, project_id: project_other.id)

		expect(sp1.save).to be_truthy
		expect(sp2.save).to be_falsy
		expect(sp2.errors[:nickname][0]).to include('already been taken')
		expect(sp3.save).to be_truthy
		expect(sp4.save).to be_falsy
		expect(sp2.errors[:nickname][0]).to include('already been taken')
	end

	it 'creating new record without logs sets logs to an empty array' do
		student = FactoryGirl.create(:student)
		project = FactoryGirl.create(:project)
		sp =  StudentsProject.new(nickname: "yo", student_id: student.id, project_id: project.id)

		expect(sp.save).to be_truthy
		expect(sp.logs.class).to eq(Array)
		expect(sp.logs).to eq([])
	end

	it 'sets points to 0 when first created' do
		student = FactoryGirl.create(:student)
		project = FactoryGirl.create(:project)
		sp =  StudentsProject.new(nickname: "yo", student_id: student.id, project_id: project.id)

		expect(sp.save).to be_truthy
		expect(sp.points).to eq 0
	end

	context 'validates format of logs' do
		before :each do
			student = FactoryGirl.create(:student)
			project = FactoryGirl.create(:project)
			@sp =  StudentsProject.new(nickname: "yo", student_id: student.id, project_id: project.id)
			expect(@sp.save).to be_truthy
		end

		it 'valid' do
			@sp.add_log(JSON.parse({ date_worked: (DateTime.now - 1.day).to_i.to_s, date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
			expect(@sp.save).to be_truthy
		end

		it 'invalid, wrong formatting' do
			@sp.add_log(JSON.parse([{ date_worked: (DateTime.now - 1.day).to_i.to_s, date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }].to_json))
			expect(@sp.save).to be_falsy
			expect(@sp.errors[:log_entry][0]).to include('not a Hash')
		end

		it 'invalid, missing parameter' do
			@sp.add_log(JSON.parse({  date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
			expect(@sp.save).to be_falsy
			expect(@sp.errors[:log_entry][0]).to include("missing")
		end

		it 'invalid, extra parameters' do
			@sp.add_log(JSON.parse({ extra: "invalid", date_worked: (DateTime.now - 1.day).to_i.to_s, date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
			expect(@sp.save).to be_falsy
			expect(@sp.errors[:log_entry][0]).to include("wrong number of parameters")
		end

		it 'invalid, correct number of paramters, wrong key' do
			@sp.add_log(JSON.parse({ date_wrong_: (DateTime.now - 1.day).to_i.to_s, date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
			expect(@sp.save).to be_falsy
			expect(@sp.errors[:log_entry][0]).to include("wrong parameter key")
		end

		it 'invalid, date worked is in the future' do
			@sp.add_log(JSON.parse({ date_worked: (DateTime.now + 2.days).to_i.to_s, date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
			expect(@sp.save).to be_falsy
			expect(@sp.errors[:log_entry][0]).to include("date_worked can't be in the future")
		end

		it 'invalid, wrong datatypes for dates' do
			@sp.add_log(JSON.parse({ date_worked: "3 days", date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
			expect(@sp.save).to be_falsy
			expect(@sp.errors[:log_entry][0]).to include("must be integers")

			@sp.reload
			@sp.add_log(JSON.parse({ date_worked: DateTime.now.to_i.to_s, date_submitted: DateTime.now, time_worked: DateTime.now, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
			expect(@sp.save).to be_falsy
			expect(@sp.errors[:log_entry][0]).to include("must be integers")
		end

		it 'invalid, wrong datatypes for stage' do
			@sp.add_log(JSON.parse({ date_worked: DateTime.now.to_i.to_s, date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: {}, text: 'Worked on database and use cases' }.to_json))
			expect(@sp.save).to be_falsy
			expect(@sp.errors[:log_entry][0]).to include("stage must be a string")
		end

		it 'invalid, wrong datatypes for text' do
			@sp.add_log(JSON.parse({ date_worked: DateTime.now.to_i.to_s, date_submitted: DateTime.now.to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 3 }.to_json))
			expect(@sp.save).to be_falsy
			expect(@sp.errors[:log_entry][0]).to include("text must be a string")
		end
	end
end
