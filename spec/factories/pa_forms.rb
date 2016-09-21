FactoryGirl.define do
	factory :pa_form, class: PAForm do
    questions [{ 'question_id' => 1, 'text' => 'What?' }, { 'question_id' => 2, 'text' => 'Who?' }, { 'question_id' => 3, 'text' => 'When?' }, { 'question_id' => 4, 'text' => 'Where?' }, { 'question_id' => 5, 'text' => 'Why?' }]
    association :iteration, factory: :iteration
	end
end
