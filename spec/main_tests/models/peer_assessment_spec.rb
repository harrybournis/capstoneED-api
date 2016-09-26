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

	it '#submit should assign the current time as date_submitted' do
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

	it '#submit should not be allowed if PAForm deadline has passed' do
		peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
			answers: [{ question_id: 1, answer: 'answ' }])
		peer_assessment.save
		Timecop.travel(@pa_form.deadline + 1.day) do
			expect(peer_assessment.submit).to be_falsy
			expect(peer_assessment.errors[:date_submitted][0]).to include("deadline for the PAForm has passed")
		end
	end

	it '#submit should not be allowed if PAForm start_date has not arrived yet' do
		peer_assessment = PeerAssessment.new(pa_form: @pa_form, submitted_by: @student_by, submitted_for: @student_for,
			answers: [{ question_id: 1, answer: 'answ' }])
		peer_assessment.save
		Timecop.travel(@pa_form.start_date - 1.day) do
			expect(peer_assessment.submit).to be_falsy
			expect(peer_assessment.errors[:date_submitted][0]).to include("not yet available")
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
