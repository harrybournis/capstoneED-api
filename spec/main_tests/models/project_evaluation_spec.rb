require 'rails_helper'
require 'timecop'

RSpec.describe ProjectEvaluation, type: :model do

	it { should belong_to :user }
	it { should belong_to :project }
	it { should belong_to :iteration }
	it { should belong_to :feeling }

	it { should validate_presence_of :user_id }
	it { should validate_presence_of :project_id }
	it { should validate_presence_of :iteration_id }
	it { should validate_presence_of :feeling_id }
	it { should validate_presence_of :percent_complete }

	it 'works' do
		expect(FactoryGirl.create(:project_evaluation)).to be_truthy
	end

	it 'factorygirl creates iteration that has the same assignment as the project' do
		pe = FactoryGirl.create(:project_evaluation)
		expect(pe.iteration.assignment).to eq(pe.project.assignment)
	end

	it 'validates that iteration belongs to the project Success' do
		assignment = FactoryGirl.create(:assignment)
		project = FactoryGirl.create(:project, assignment: assignment)
		iteration = FactoryGirl.create(:iteration, assignment: assignment, start_date: DateTime.now, deadline: DateTime.now + 1.month )

		pe = FactoryGirl.build(:project_evaluation, iteration_id: iteration.id)
		pe.project = project
		pe.project.students << pe.user
		expect(pe.save).to be_truthy
	end

	it 'validates that iteration belongs to the project Error' do
		assignment = FactoryGirl.create(:assignment)
		project = FactoryGirl.create(:project)
		iteration = FactoryGirl.create(:iteration, assignment: assignment )

		pe = FactoryGirl.build(:project_evaluation)
		pe.project = project
		pe.iteration = iteration

		expect(pe.save).to be_falsy
		expect(pe.errors[:iteration_id][0]).to include('does not belong')
	end

	it 'validates that iteration is active Error' do
		now = DateTime.now
		assignment = FactoryGirl.create(:assignment)
		project = FactoryGirl.create(:project, assignment: assignment)
		iteration = FactoryGirl.create(:iteration, assignment: assignment, start_date: now, deadline: now + 2.days )

		Timecop.travel(now + 10.days) do
			pe = FactoryGirl.build(:project_evaluation)
			pe.project = project
			pe.iteration = iteration

			expect(pe.save).to be_falsy
			expect(pe.errors[:iteration_id][0]).to include("no later")
		end
	end

	it 'validates that iteration is active Success' do
		now = DateTime.now
		assignment = FactoryGirl.create(:assignment)
		project = FactoryGirl.create(:project, assignment: assignment)
		iteration = FactoryGirl.create(:iteration, assignment: assignment, start_date: now, deadline: now + 2.days )

		Timecop.travel(now + 1.days) do
			pe = FactoryGirl.build(:project_evaluation)
			pe.project = project
			pe.project.students << pe.user
			pe.iteration = iteration

			expect(pe.save).to be_truthy
		end
	end

	it 'validates that it is within the limit of project evaluations for a single iteration for a single user Error' do
		LIMITError = 2
		now = DateTime.now

		user = FactoryGirl.create(:lecturer)
		user.units << FactoryGirl.create(:unit)
		assignment = FactoryGirl.create(:assignment, lecturer: user, unit: user.units[0])
		project = FactoryGirl.create(:project, assignment: assignment, lecturer: user)
		iteration = FactoryGirl.create(:iteration, assignment: assignment, start_date: now, deadline: now + 2.months)
		feeling = FactoryGirl.create(:feeling)

		pe = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feeling_id: feeling.id)
		expect(pe.save).to be_truthy
		pe2 = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feeling_id: feeling.id)
		expect(pe2.save).to be_truthy

		Timecop.travel(now + 3.days) do
			pe3 = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feeling_id: feeling.id)

			expect(pe3.save).to be_falsy
			expect(pe3.errors[:iteration_id][0]).to include('limit')
		end
	end

	it 'validates that it is within the limit of project evaluations for a single iteration for a single user accounting for Lecturer' do
		LIMITLecturer = 2
		now = DateTime.now

		user = FactoryGirl.create(:lecturer)
		user.units << FactoryGirl.create(:unit)
		assignment = FactoryGirl.create(:assignment, lecturer: user, unit: user.units[0])
		project = FactoryGirl.create(:project, assignment: assignment, lecturer: user)
		iteration = FactoryGirl.create(:iteration, assignment: assignment, start_date: now, deadline: now + 2.months)
		feeling = FactoryGirl.create(:feeling)

		pe = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feeling_id: feeling.id)
		expect(pe.save).to be_truthy
		pe2 = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feeling_id: feeling.id)
		expect(pe2.save).to be_truthy

		Timecop.travel(now + 3.days) do
			different_project = FactoryGirl.create(:project, assignment: assignment, lecturer: user)
			pe3 = ProjectEvaluation.new(project_id: different_project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feeling_id: feeling.id)

			expect(pe3.save).to be_truthy
		end
	end

	it 'validates that it is within the limit of project evaluations for a single iteration for a single user Success' do
		LIMITSuccess = 2
		now = DateTime.now

		user = FactoryGirl.create(:lecturer)
		user.units << FactoryGirl.create(:unit)
		assignment = FactoryGirl.create(:assignment, lecturer: user, unit: user.units[0])
		project = FactoryGirl.create(:project, assignment: assignment, lecturer: user)
		iteration = FactoryGirl.create(:iteration, assignment: assignment, start_date: now, deadline: now + 2.months)
		feeling = FactoryGirl.create(:feeling)

		pe = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feeling_id: feeling.id)
		expect(pe.save).to be_truthy
		pe2 = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feeling_id: feeling.id)
		expect(pe2.save).to be_truthy

		Timecop.travel(now + 3.days) do
			user = FactoryGirl.create(:student)
			project.students << user
			pe3 = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feeling_id: feeling.id)

			expect(pe3.save).to be_truthy
		end
	end

	it 'validates that the user is associated with the project' do
		irrelevant_student = FactoryGirl.create(:student)
		pe = FactoryGirl.build(:project_evaluation)
		pe.user = irrelevant_student

		expect(pe.save).to be_falsy
		expect(pe.errors[:user_id][0]).to include("not associated")
	end

	it 'validates that percent complete is between 0 and 100' do
		pe = FactoryGirl.build(:project_evaluation, percent_complete: 101)

		expect(pe.save).to be_falsy
		expect(pe.errors[:percent_complete][0]).to include("between 0 and 100")
	end

	it 'sets the current time as date_submitted' do
		now = DateTime.now

		Timecop.freeze(now) do
			pe = FactoryGirl.create(:project_evaluation, date_submitted: nil)
			pe.save

			expect(pe.date_submitted.to_i).to eq(now.to_i)
		end
	end

	it 'does not mess up the date submitted when updating' do
		now = DateTime.now

		Timecop.freeze(now) do
			pe = FactoryGirl.create(:project_evaluation, date_submitted: nil)
			pe.save

			expect(pe.date_submitted.to_i).to eq(now.to_i)

			pe.reload
			new_date_submitted = DateTime.now + 1.day

			pe.date_submitted = new_date_submitted
			pe.save

			expect(pe.date_submitted).to eq(new_date_submitted)
		end
	end
end
