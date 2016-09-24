require 'rails_helper'

RSpec.describe PAForm, type: :model do

	subject(:pa_form) { FactoryGirl.build(:pa_form) }

	it { should belong_to :iteration }
	it { should have_many :peer_assessments }
	it { should validate_presence_of :iteration }

	it 'validates presence of questions' do
		iteration = FactoryGirl.create(:iteration)
		pa_form = PAForm.create(iteration_id: iteration.id)
		expect(pa_form.save).to be_falsy
		expect(pa_form.errors['questions'][0]).to eq("can't be blank")
	end

	it 'jsonb keeps questions order intact' do
		iteration = FactoryGirl.create(:iteration)
		pa_form = PAForm.create(iteration_id: iteration.id,
			questions: ["1st", "2nd" ,"3rd" ])
		pa_form.reload
		expect(pa_form.questions[1]).to eq({ 'question_id' => 2, 'text' => "2nd" })
	end


	it 'store_questions formats questions in the correct form' do
		questions = ['What?', 'Who?', 'When?', 'Where?']
		pa_form = PAForm.new(iteration_id: 1, questions: questions)

		expect(pa_form.questions).to eq([
			{ 'question_id' => 1, 'text' => 'What?' }, { 'question_id' => 2, 'text' => 'Who?' }, { 'question_id' => 3, 'text' => 'When?' }, { 'question_id' => 4, 'text' => 'Where?' }])
	end


	it 'validates the format of the questions' do
		iteration = FactoryGirl.create(:iteration)
		pa_form = PAForm.new(iteration_id: iteration.id,
			questions: [{ 'question_id' => 1, 'text' => "1st" }, { 'question_id' => 2, 'text' => "2nd" }, { 'question_id' => 3, 'text' => "3rd" }])
		expect(pa_form.save).to be_falsy

		pa_form = PAForm.new(iteration_id: iteration.id,
			questions: { 'questions_id' => 1, 'text' => "1st" })
		expect(pa_form.save).to be_falsy
		expect(pa_form.errors[:questions].first).to include("can't be blank")

		pa_form = PAForm.new(iteration_id: iteration.id,
			questions: [])
		expect(pa_form.save).to be_falsy
		expect(pa_form.errors[:questions].first).to include("can't be blank")

		pa_form = PAForm.new(iteration_id: iteration.id, questions: ['dkd', 4])
		expect(pa_form.save).to be_falsy
		expect(pa_form.errors['questions'][0]).to include("can't be blank")
	end
end
