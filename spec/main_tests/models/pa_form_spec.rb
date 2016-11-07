require 'rails_helper'

RSpec.describe PAForm, type: :model do

	subject(:pa_form) { FactoryGirl.build(:pa_form) }

	it { should belong_to :iteration }
	it { should have_many :peer_assessments }
	it { should have_many(:extensions).through(:iteration) }
	it { should validate_presence_of :iteration }
	it { should validate_presence_of :start_date }
	it { should validate_presence_of :deadline }

	it 'validates presence of questions' do
		iteration = FactoryGirl.create(:iteration)
		pa_form = PAForm.create(iteration_id: iteration.id)
		expect(pa_form.save).to be_falsy
		expect(pa_form.errors['questions'][0]).to eq("can't be blank")
	end

	it 'jsonb keeps questions order intact' do
		iteration = FactoryGirl.create(:iteration)
		pa_form = PAForm.create(iteration_id: iteration.id,
			questions: ["1st", "2nd" ,"3rd" ], start_date: iteration.start_date, deadline: iteration.deadline)
		pa_form.reload
		expect(pa_form.questions[1]).to eq({ 'question_id' => 2, 'text' => "2nd" })
	end


	it '#store_questions formats questions in the correct form' do
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

	it '.active returns only the forms that can be currently submitted' do
		now = DateTime.now
		iteration1 = FactoryGirl.create(:iteration, start_date: now + 3.days, deadline: now + 5.days)
		iteration2 = FactoryGirl.create(:iteration, start_date: now + 4.days, deadline: now + 6.days)
		FactoryGirl.create(:pa_form, iteration: iteration1)
		FactoryGirl.create(:pa_form, iteration: iteration2)
		expect(PAForm.all.length).to eq 2

		Timecop.travel(now + 3.days + 1.minute) do
			expect(PAForm.active.length).to eq 1
		end

		Timecop.travel(now + 4.days + 1.minute) do
			expect(PAForm.active.length).to eq 2
		end

		Timecop.travel(now + 5.days + 1.minute) do
			expect(PAForm.active.length).to eq 1
		end

		Timecop.travel(now + 6.days + 1.minute) do
			expect(PAForm.active.length).to eq 0
		end
	end

	it 'validates that deadline with extension adds the time of the extension' do
		start = DateTime.now
		finish = start + 1.day
		pa_form = FactoryGirl.create(:pa_form, start_date: start, deadline: finish)
		team = FactoryGirl.create(:team)
		extension  = FactoryGirl.create(:extension, iteration_id: pa_form.iteration_id, team_id: team.id)
		expect(pa_form.deadline_with_extension_for_team(team)).to eq(Time.at(finish.to_i + extension.extra_time).to_datetime)
	end

	it 'return only deadline if iteration does not exist' do
		start = DateTime.now
		finish = start + 1.day
		pa_form = FactoryGirl.create(:pa_form, start_date: start, deadline: finish)
		team = FactoryGirl.create(:team)
		wrong_iteration = FactoryGirl.create(:iteration)
		extension  = FactoryGirl.create(:extension, iteration_id: wrong_iteration.id, team_id: team.id)
		expect(pa_form.deadline_with_extension_for_team(team)).to eq(finish)
	end
end
