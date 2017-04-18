require 'rails_helper'

RSpec.describe PaForm, type: :model do

	subject(:pa_form) { FactoryGirl.build(:pa_form) }

	it { should belong_to :iteration }
	it { should have_many :peer_assessments }
	it { should have_many :extensions }
	it { should validate_presence_of :iteration }
	it { should validate_presence_of :start_offset }
	it { should validate_presence_of :end_offset }

	describe 'Questions' do

		before :each do
			@type = create :question_type
			@type2 = create :question_type
		end

		it 'validates presence of questions' do
			iteration = FactoryGirl.create(:iteration)
			pa_form = PaForm.create(iteration_id: iteration.id)
			expect(pa_form.save).to be_falsy
			expect(pa_form.errors['questions'][0]).to eq("can't be blank")
		end

		it 'jsonb keeps questions order intact' do
			iteration = FactoryGirl.create(:iteration)
			pa_form = PaForm.create(iteration_id: iteration.id,
															start_offset: iteration.start_date,
															end_offset: iteration.deadline,
															questions: [{ 'text' => "1st", 'type_id' => @type.id },
																					{ 'text' => "2nd", 'type_id' => @type.id },
																					{ 'text' => "3rd", 'type_id' => @type.id }])
			pa_form.reload
			expect(pa_form.questions[1]).to eq({ 'question_id' => 2, 'text' => "2nd", 'type_id' => @type.id })
		end

		it '#store_questions formats questions in the correct form' do
			iteration = FactoryGirl.create(:iteration)
			questions = [{ 'text' => 'What?', 'type_id' => @type2.id },
									{ 'text' => 'Who?', 'type_id' => @type2.id },
									{ 'text' => 'When?', 'type_id' => @type.id },
									{ 'text' => 'Where?', 'type_id' => @type2.id }]
			pa_form = create :pa_form, iteration_id: iteration.id, questions: questions

			expect(pa_form.questions).to eq([
				{ 'question_id' => 1, 'text' => 'What?', 'type_id' => @type2.id },
				{ 'question_id' => 2, 'text' => 'Who?', 'type_id' => @type2.id },
				{ 'question_id' => 3, 'text' => 'When?', 'type_id' => @type.id },
				{ 'question_id' => 4, 'text' => 'Where?', 'type_id' => @type2.id }])
			expect(pa_form.save).to be_truthy
		end

		it 'validates the format of the questions' do
			iteration = FactoryGirl.create(:iteration)
			# wrong format
			pa_form = build :pa_form, iteration_id: iteration.id,
											questions: [{ 'question_id' => 1, 'text' => "1st", 'type_id' => @type2.id },
																	{ 'question_id' => 2, 'text' => "2nd", 'type_id' => @type.id },
																	{ 'question_id' => 3, 'text' => "3rd"}]
			expect(pa_form.save).to be_falsy
			expect(pa_form.errors[:questions].first).to include "can't be blank"

			# not an array
			pa_form = build :pa_form, iteration_id: iteration.id,
																questions: { 'questions_id' => 1, 'text' => "1st" }
			expect(pa_form.save).to be_falsy
			expect(pa_form.errors[:questions].first).to include("can't be blank")

			# empty array
			pa_form = build :pa_form, iteration_id: iteration.id, questions: []
			expect(pa_form.save).to be_falsy
			expect(pa_form.errors[:questions].first).to include("can't be blank")

			# empty string as text question
			questions = [{ 'text' => 'What?', 'type_id' => @type.id},
									{ 'text' => '', 'type_id' => @type.id},
									{ 'text' => 'When?', 'type_id' => @type.id},
									{ 'text' => 'Where?', 'type_id' => @type.id}]
			pa_form = build :pa_form, iteration_id: iteration.id, questions: questions
			expect(pa_form.save).to be_falsy
			expect(pa_form.errors['questions'][0]).to include("can't be blank")
		end

		it 'returns error if type_id is does not exist in database' do
			iteration = FactoryGirl.create(:iteration)
			questions = [{ 'text' => 'What?', 'type_id' => @type2.id},
									{ 'text' => 'Who?', 'type_id' => 5666},
									{ 'text' => 'When?', 'type_id' => @type.id},
									{ 'text' => 'Where?', 'type_id' => @type2.id}]
			pa_form = build :pa_form, iteration_id: iteration.id, questions: questions
			expect(pa_form.save).to be_falsy
			expect(pa_form.errors[:questions].first).to include 'type_id does not match'
		end
	end

	describe 'Dates' do
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

	it '#active? returns true if current time is after start_date and before deadline' do
		now = DateTime.now
		iteration = create :iteration, start_date: now, deadline: now + 1.second
		expect(iteration.valid?).to be_truthy
		pa = create :pa_form, iteration: iteration, start_offset: 1.minute.to_i, end_offset: 2.days.to_i
		expect(pa.valid?).to be_truthy

		Timecop.travel now + 1.day do
			expect(pa.active?).to be_truthy
		end

		Timecop.travel now + 3.days do
			expect(pa.active?).to be_falsy
		end
	end
end
