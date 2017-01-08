require 'rails_helper'
require 'timecop'

RSpec.describe PeerAssessment, type: :model do

	it { should belong_to :pa_form }
	it { should belong_to :submitted_by }
	it { should belong_to :submitted_for }
	it { should belong_to :project }

	it { should validate_presence_of :pa_form_id }
	it { should validate_presence_of :submitted_for_id }
	it { should validate_presence_of :submitted_by_id }
	it { should validate_presence_of :project_id }

	it { should validate_presence_of :answers }

	before(:all) do
		@student_by = FactoryGirl.create(:student_confirmed)
		@student_for = FactoryGirl.create(:student_confirmed)
		@pa_form  = FactoryGirl.create(:pa_form)
		@project = FactoryGirl.create(:project, assignment: @pa_form.assignment)
		create :students_project, student: @student_by, project: @project
		create :students_project, student: @student_for, project: @project
	end

	it 'works' do
		pa = FactoryGirl.build(:peer_assessment)
		expect(pa.save).to be_truthy
	end

	it 'automatically saves the project_id from the pa_form before save' do
		pa = FactoryGirl.build(:peer_assessment)

		expect(pa.project_id).to be_falsy
		expect(pa.save).to be_truthy
		expect(pa.project).to be_truthy
	end

	it 'should validate format of answers' do
		peer_assessment = FactoryGirl.build(:peer_assessment, pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
			answers: { question_id: 1, answer: 'answ' })
		expect(peer_assessment.save).to be_falsy
		expect(peer_assessment.errors[:answers][0]).to include('not an Array')

		peer_assessment = FactoryGirl.build(:peer_assessment, pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
			answers: [{ question_id: 1, answer: 'answ', other: 'field' }])
		expect(peer_assessment.save).to be_falsy
		expect(peer_assessment.errors[:answers][0]).to include('invalid parameters')

		peer_assessment = FactoryGirl.build(:peer_assessment, pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
			answers: [{ question_id: 1, answer: 'ans' }, { question_id: 2 }])
		expect(peer_assessment.save).to be_falsy
		expect(peer_assessment.errors[:answers][0]).to include('invalid parameters')

		peer_assessment = FactoryGirl.build(:peer_assessment, pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
			answers: [])
		expect(peer_assessment.save).to be_falsy
		expect(peer_assessment.errors[:answers][0]).to include("can't be blank")
	end


	it '#submit assigns the current time as date_submitted' do
		time_now = @pa_form.start_date + 1.minute
		Timecop.freeze(time_now) do
			peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
				answers: [{ question_id: 1, answer: 'answ' }])
			expect(peer_assessment.save).to be_truthy
			expect(peer_assessment.submit).to be_truthy
			peer_assessment.reload
			expect(peer_assessment.date_submitted.to_i).to eq(time_now.to_i)
		end
	end


	describe '#submit fails if' do
		it 'user has already peer assessed this student for this form' do
			Timecop.travel(@pa_form.start_date + 1.day) do
				peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
					answers: [{ question_id: 1, answer: 'answ' }])
				peer_assessment.save
				expect(peer_assessment.submit).to be_truthy

				peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
					answers: [{ question_id: 1, answer: 'answ' }])
				expect(peer_assessment.save).to be_falsy
				expect(peer_assessment.errors[:pa_form][0]).to include('has already been completed for this student')
			end
		end

		it 'PAForm deadline has passed' do
			peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
				answers: [{ question_id: 1, answer: 'answ' }])
			peer_assessment.save
			Timecop.travel(@pa_form.deadline + 1.day) do
				expect(peer_assessment.submit).to be_falsy
				expect(peer_assessment.errors[:date_submitted][0]).to include("deadline for the PAForm has passed")
			end
		end

		it 'PAForm start_date has not arrived yet' do
			peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
				answers: [{ question_id: 1, answer: 'answ' }])
			peer_assessment.save
			Timecop.travel(@pa_form.start_date - 1.day) do
				expect(peer_assessment.submit).to be_falsy
				expect(peer_assessment.errors[:date_submitted][0]).to include("not yet available")
			end
		end

		it 'PAForm id is not from a Project that the submitted_by Student belongs to' do
			wrong_pa = FactoryGirl.create(:pa_form)
			peer_assessment = PeerAssessment.new(pa_form: wrong_pa, submitted_by: @student_by, submitted_for: @student_for,
				answers: [{ question_id: 1, answer: 'answ' }])
			peer_assessment.save
			Timecop.travel(wrong_pa.start_date + 1.day) do
				expect(peer_assessment.submit).to be_falsy
				expect(peer_assessment.errors[:pa_form][0]).to include('is for an Assignment that the current user does not belong to')
			end
		end

		it 'submitted_for is not in the same Project as user' do
			irrelevant_project = FactoryGirl.create(:project)
			irrelevant_student = FactoryGirl.create(:student_confirmed)
			create :students_project, student: irrelevant_student, project: irrelevant_project

			peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: irrelevant_student,
				answers: [{ question_id: 1, answer: 'answ' }])
			peer_assessment.save

			Timecop.travel(@pa_form.start_date + 1.day) do
				expect(peer_assessment.submit).to be_falsy
				expect(peer_assessment.errors[:submitted_for][0]).to include('not in the same Project')

				peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
					answers: [{ question_id: 1, answer: 'answ' }])
				peer_assessment.save

				expect(peer_assessment.submit).to be_truthy
			end
		end
	end

	it '#submitted? should return false if date_submitted is nil' do
		peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
			answers: [{ question_id: 1, answer: 'answ' }])
		peer_assessment.save
		expect(peer_assessment.submitted?).to be_falsy
		Timecop.travel(@pa_form.start_date + 1.day) do
			peer_assessment.submit
			expect(peer_assessment.submit).to be_truthy
		end
		expect(peer_assessment.submitted?).to be_truthy
	end

	describe '.api_query' do

		before :all do
			@pa_form2  = FactoryGirl.create(:pa_form)
			@project2 = FactoryGirl.create(:project, assignment: @pa_form2.assignment)
			create :students_project, student: @student_by, project: @project2
			create :students_project, student: @student_for, project: @project2
			@student_by2 = FactoryGirl.create(:student_confirmed)
			@student_for2 = FactoryGirl.create(:student_confirmed)
			create :students_project, student: @student_by2, project: @project
			create :students_project, student: @student_for2, project: @project

			pa = FactoryGirl.build(:peer_assessment, pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
				answers: [{ question_id: 1, answer: 'answ' }])
			pa2 = FactoryGirl.create(:peer_assessment, pa_form: @pa_form2, submitted_by: @student_by, submitted_for: @student_for,
				answers: [{ question_id: 1, answer: 'answ' }]) # same students, different form
			pa3 = FactoryGirl.build(:peer_assessment, pa_form: @pa_form, submitted_by: @student_by2, submitted_for: @student_for2,
				answers: [{ question_id: 1, answer: 'answ' }]) # same form, different students
			peer_assessments_rest = FactoryGirl.create_list(:peer_assessment, 5)
			expect(pa.save).to be_truthy
			expect(pa2.save).to be_truthy
			expect(pa3.save).to be_truthy
			@iteration = @pa_form.iteration
		end

		it 'queries using pa_form_id and submitted_by/submitted_for' do
			expect(PeerAssessment.where(submitted_by_id: @student_by.id).count).to eq(2)
			expect(PeerAssessment.api_query({ "pa_form_id" => @pa_form.id }).count).to eq(2)
			expect(PeerAssessment.api_query({ "submitted_by_id" => @student_by.id, "pa_form_id" => @pa_form.id }).count).to eq(1)
			expect(PeerAssessment.api_query({ "submitted_for_id" => @student_for.id, "pa_form_id" => @pa_form.id }).count).to eq(1)
		end

		it 'queries using iteration_id' do
			expect(@iteration.peer_assessments.count).to eq(2)
			expect(PeerAssessment.api_query({ "iteration_id" => @iteration.id }).count).to eq(2)
		end

		it 'combines iteration_id and submitted_for' do
			expect(@iteration.peer_assessments.count).to eq(2)
			expect(PeerAssessment.api_query({ "iteration_id" => @iteration.id, "submitted_by_id" => @student_by.id }).count).to eq(1)
		end

		it 'queries using project_id' do
			expect(PeerAssessment.where(project_id: @project.id).count).to eq(2)

			expect(PeerAssessment.api_query({ "project_id" => @project.id }).count).to eq(2)
		end

		it 'queries using both project_id and iteration_id' do
			new_iteration = FactoryGirl.create(:iteration, assignment: @pa_form.assignment)
			new_pa_form = FactoryGirl.create(:pa_form, iteration: new_iteration)
			new_pa = FactoryGirl.create(:peer_assessment, pa_form: new_pa_form, submitted_by: @student_by, submitted_for: @student_for,
				answers: [{ question_id: 1, answer: 'answ' }])

			expect(PeerAssessment.where(project_id: @project.id).count).to eq(3)
			expect(PeerAssessment.api_query({ "project_id" => @project.id, "iteration_id" => new_iteration.id }).count).to eq(1)
			expect(PeerAssessment.api_query({ "project_id" => @project.id, "iteration_id" => @iteration.id }).count).to eq(2)
		end

		it 'queries with everything' do
			expect(PeerAssessment.api_query({ "project_id" => @project.id, "iteration_id" => @iteration.id,
			"submitted_for_id" => @student_for.id, "submitted_by_id" => @student_by.id, "pa_form_id" => @pa_form.id }).count)
			.to eq(1)
		end

	end

end
