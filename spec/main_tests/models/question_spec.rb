require 'rails_helper'

RSpec.describe Question, type: :model do
	subject(:question) { FactoryGirl.build(:question) }

	it { should validate_presence_of :text }
	it { should validate_presence_of :lecturer_id }

	it { should belong_to :lecturer }

	it 'works' do
		q = FactoryGirl.build(:question)
		puts q.errors unless q.valid?
		expect(q.valid?).to be_truthy
	end
end
