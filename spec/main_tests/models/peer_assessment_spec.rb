require 'rails_helper'

RSpec.describe PeerAssessment, type: :model do

	it { should belong_to :pa_form }
	it { should belong_to :submitted_by }
	it { should belong_to :submitted_for }

	it { should validate_presence_of :pa_form_id }
	it { should validate_presence_of :submitted_for_id }
	it { should validate_presence_of :submitted_by_id }
	it { should validate_presence_of :date_submitted }
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
end
