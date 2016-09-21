require 'rails_helper'

RSpec.describe PAForm, type: :model do

	it 'questions_in_order return questions with their text ordered' do
		pa_form = PAForm.create(iteration_id: 1,
			questions: [{ 'question_id' => 1, 'text' => "1st" }, { 'question_id' => 2, 'text' => "2nd" }, { 'question_id' => 3, 'text' => "3rd" }],
			questions_order: [{ 'question_id' => 1, 'order' => 3 }, { 'question_id' => 2, 'order' => 1 }, { 'question_id' => 3, 'order' => 2 }])

		expect(pa_form.questions_in_order).to eq(["2nd", "3rd", "1st"])
	end

end
