require 'rails_helper'

RSpec.describe Question, type: :model do
	subject(:question) { FactoryBot.build(:question) }

	it { should validate_presence_of :text }
  it { should validate_presence_of :lecturer_id }
	it { should validate_presence_of :question_type_id }

  it { should belong_to :lecturer }
	it { should belong_to :question_type }

	it 'works' do
		q = FactoryBot.build(:question)
		puts q.errors unless q.valid?
		expect(q.valid?).to be_truthy
	end
end
