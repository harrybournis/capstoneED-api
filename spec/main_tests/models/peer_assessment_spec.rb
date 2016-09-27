require 'rails_helper'
require 'timecop'

RSpec.describe PeerAssessment, type: :model do

	it { should belong_to :pa_form }
	it { should belong_to :submitted_by }
	it { should belong_to :submitted_for }

	it { should validate_presence_of :pa_form_id }
	it { should validate_presence_of :submitted_for_id }
	it { should validate_presence_of :submitted_by_id }

	it { should validate_presence_of :answers }

	before(:all) do
		@student_by = FactoryGirl.create(:student_confirmed)
		@student_for = FactoryGirl.create(:student_confirmed)
		@pa_form  = FactoryGirl.create(:pa_form)
		@team = FactoryGirl.create(:team, project: @pa_form.project)
		@team.students << @student_by
		@team.students << @student_for
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
				expect(peer_assessment.errors[:pa_form][0]).to include('is for a Project that the current user does not belong to')
			end
		end

		it 'submitted_for is not in the same Team as user' do
			irrelevant_team = FactoryGirl.create(:team)
			irrelevant_student = FactoryGirl.create(:student_confirmed)
			irrelevant_team.students << irrelevant_student

			peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: irrelevant_student,
				answers: [{ question_id: 1, answer: 'answ' }])
			peer_assessment.save

			Timecop.travel(@pa_form.start_date + 1.day) do
				expect(peer_assessment.submit).to be_falsy
				expect(peer_assessment.errors[:submitted_for][0]).to include('not in the same Team')

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
			expect(peer_assessment.submit).to be_truthy
		end
		expect(peer_assessment.submitted?).to be_truthy
	end
end
