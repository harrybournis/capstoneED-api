require 'rails_helper'

RSpec.describe Question::PredefinedQuestion, type: :model do
	subject(:predefined_question) { FactoryGirl.build(:predefined_question) }

	it { should validate_presence_of :type }
	it { should validate_presence_of :text }
	it { should validate_presence_of :category }
	it { should validate_absence_of :lecturer_id }
end
