require 'rails_helper'

RSpec.describe Question, type: :model do
	subject(:question) { FactoryGirl.build(:question) }

	it { should validate_presence_of :text }
	it { should validate_presence_of :category }
	it { should validate_presence_of :lecturer_id }

	it { should belong_to :lecturer }
	it { should have_many :questions_sections }
	it { should have_many :sections }

	it 'works' do
		q = FactoryGirl.build(:question)
		binding.pry
		puts q.errors unless q.valid?
		expect(q.valid?).to be_truthy
	end
end
