require 'rails_helper'

RSpec.describe SaveQuestionsService, type: :model do

  before :each do
    @lecturer = create :lecturer_confirmed
    q1 = FactoryGirl.create :question_type, category: 'text', friendly_name: 'Text'
    q2 = FactoryGirl.create :question_type, category: 'number', friendly_name: 'Number'
    q3 = FactoryGirl.create :question_type, category: 'rank', friendly_name: 'Rank'

    @valid_questions = [{ "question_id" => 1, "text" => 'Who is it?', 'type_id' => q2.id },
                        { "question_id" => 2, "text" => 'Human?', 'type_id' => q2.id },
                        { "question_id" => 3, "text" => 'Hello?', 'type_id' => q3.id },
                        { "question_id" => 4, "text" => 'Favorite Power Ranger?', 'type_id' => q1.id }]
    @invalid_questions = ['Who is it?', 'Human?']
  end

  describe '.initialize' do
    it 'returns true if hash has the correct form and lecturer_id is not nil' do
      expect(SaveQuestionsService.new(@valid_questions, @lecturer.id)).to be_truthy
    end
  end

  describe '#call' do
    it 'saves records if the text is unique' do
      service = SaveQuestionsService.new(@valid_questions, @lecturer.id)
      expect(service).to be_truthy

      expect {
        service.call
      }.to change { Question.all.count }.by 4

      @valid_questions.each do |q|
        expect(Question.find_by(lecturer_id: @lecturer.id, text: q['text'])).to be_truthy
      end
    end

    it 'ignores text that already exists in the database' do
      expect(create :question, lecturer_id: @lecturer.id, text: @valid_questions[0]['text'], question_type_id: @valid_questions[0]['type_id']).to be_truthy

      service = SaveQuestionsService.new(@valid_questions, @lecturer.id)
      expect(service).to be_truthy

      expect {
        service.call
      }.to change { Question.all.count }.by 3

      @valid_questions[1..-1].each do |q|
        expect(Question.find_by(lecturer_id: @lecturer.id, text: q['text'])).to be_truthy
      end
    end
  end
end
