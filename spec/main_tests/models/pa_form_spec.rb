require 'rails_helper'

RSpec.describe PaForm, type: :model do

	subject(:pa_form) { FactoryGirl.build(:pa_form) }

	it { should belong_to :iteration }
	it { should have_many :peer_assessments }
	it { should have_many :extensions }
	it { should validate_presence_of :iteration }
	it { should validate_presence_of :start_offset }
	it { should validate_presence_of :end_offset }

	it 'validates presence of questions' do
		iteration = FactoryGirl.create(:iteration)
		pa_form = PaForm.create(iteration_id: iteration.id)
		expect(pa_form.save).to be_falsy
		expect(pa_form.errors['questions'][0]).to eq("can't be blank")
	end

	it 'jsonb keeps questions order intact' do
		iteration = FactoryGirl.create(:iteration)
		pa_form = PaForm.create(iteration_id: iteration.id,
			questions: ["1st", "2nd" ,"3rd" ], start_offset: iteration.start_date, end_offset: iteration.deadline)
		pa_form.reload
		expect(pa_form.questions[1]).to eq({ 'question_id' => 2, 'text' => "2nd" })
	end

	it 'translates the start_date and deadline to start_offset and deadline' do
		pa = PaForm.new attributes_for(:pa_form).except(:start_offset, :end_offset).merge!(start_date: DateTime.now + 2.day, deadline: DateTime.now + 4.days, iteration_id: create(:iteration).id)

		expect(pa.save).to be_truthy
	end

	it '#start_date= sets start_offset' do
		pa = PaForm.new attributes_for(:pa_form).except(:start_offset).merge! iteration_id: create(:iteration).id
		expect(pa.start_offset).to be_falsy
		start_date = pa.iteration.deadline + pa.end_offset - 1.day

		pa.start_date = start_date
		expect(pa.save).to be_truthy
		expect(pa.start_offset).to be_truthy
		expect(pa.start_offset).to eq start_date.to_i - pa.iteration.deadline.to_i
	end

	it '#deadline= sets end_offset' do
		pa = PaForm.new attributes_for(:pa_form).except(:end_offset).merge! iteration_id: create(:iteration).id
		expect(pa.end_offset).to be_falsy
		deadline = pa.iteration.deadline + pa.start_offset + 1.day

		pa.deadline = deadline
		expect(pa.save).to be_truthy
		expect(pa.end_offset).to be_truthy
		expect(pa.end_offset).to eq deadline.to_i - pa.iteration.deadline.to_i
	end

	it '#store_questions formats questions in the correct form' do
		questions = ['What?', 'Who?', 'When?', 'Where?']
		pa_form = PaForm.new(iteration_id: 1, questions: questions)

		expect(pa_form.questions).to eq([
			{ 'question_id' => 1, 'text' => 'What?' }, { 'question_id' => 2, 'text' => 'Who?' }, { 'question_id' => 3, 'text' => 'When?' }, { 'question_id' => 4, 'text' => 'Where?' }])
	end

	it 'validates the format of the questions' do
		iteration = FactoryGirl.create(:iteration)
		pa_form = PaForm.new(iteration_id: iteration.id,
			questions: [{ 'question_id' => 1, 'text' => "1st" }, { 'question_id' => 2, 'text' => "2nd" }, { 'question_id' => 3, 'text' => "3rd" }])
		expect(pa_form.save).to be_falsy

		pa_form = PaForm.new(iteration_id: iteration.id,
			questions: { 'questions_id' => 1, 'text' => "1st" })
		expect(pa_form.save).to be_falsy
		expect(pa_form.errors[:questions].first).to include("can't be blank")

		pa_form = PaForm.new(iteration_id: iteration.id,
			questions: [])
		expect(pa_form.save).to be_falsy
		expect(pa_form.errors[:questions].first).to include("can't be blank")

		pa_form = PaForm.new(iteration_id: iteration.id, questions: ['dkd', 4])
		expect(pa_form.save).to be_falsy
		expect(pa_form.errors['questions'][0]).to include("can't be blank")
	end

	it '.active returns only the forms that can be currently submitted' do
		now = DateTime.now
		iteration1 = FactoryGirl.create(:iteration, start_date: now + 3.days, deadline: now + 5.days)
		iteration2 = FactoryGirl.create(:iteration, start_date: now + 4.days, deadline: now + 6.days)
		FactoryGirl.create(:pa_form, iteration: iteration1)
		FactoryGirl.create(:pa_form, iteration: iteration2)
		expect(PaForm.all.length).to eq 2

		Timecop.travel(now + 3.days + 1.minute) do
			expect(PaForm.active.length).to eq 1
		end

		Timecop.travel(now + 4.days + 1.minute) do
			expect(PaForm.active.length).to eq 2
		end

		Timecop.travel(now + 5.days + 1.minute) do
			expect(PaForm.active.length).to eq 1
		end

		Timecop.travel(now + 6.days + 1.minute) do
			expect(PaForm.active.length).to eq 0
		end
	end

	it 'validates that deadline with extension adds the time of the extension' do
		start = 1.day.to_i
		finish = 4.days.to_i
		pa_form = FactoryGirl.create(:pa_form, start_offset: start, end_offset: finish)
		project = FactoryGirl.create(:project)
		extension  = FactoryGirl.create(:extension, deliverable_id: pa_form.id, project_id: project.id)
		expect(pa_form.deadline_with_extension_for_project(project)).to eq(Time.at(pa_form.iteration.deadline.to_i + finish + extension.extra_time).to_datetime)
	end

	it 'return only deadline if iteration does not exist' do
		start = 1.day.to_i
		finish = 4.days.to_i
		pa_form = FactoryGirl.create(:pa_form, start_offset: start, end_offset: finish)
		project = FactoryGirl.create(:project)
		wrong_pa = FactoryGirl.create(:pa_form)
		extension  = FactoryGirl.create(:extension, deliverable_id: wrong_pa.id, project_id: project.id)
		expect(pa_form.deadline_with_extension_for_project(project)).to eq(Time.at(pa_form.iteration.deadline.to_i + finish).to_datetime)
	end
end
