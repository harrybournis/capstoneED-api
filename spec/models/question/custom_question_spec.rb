require 'rails_helper'

RSpec.describe Question::CustomQuestion, type: :model do
	subject(:custom_question) { FactoryGirl.build(:custom_question) }

	it { should validate_presence_of :type }
	it { should validate_presence_of :text }
	it { should validate_presence_of :category }
	it { should validate_presence_of :lecturer_id }

	it { should belong_to :lecturer }
end
