require 'rails_helper'

RSpec.describe Iteration, type: :model do
	subject(:iteration) { FactoryGirl.create(:iteration) }

	it { should validate_presence_of(:name) }
	it { should validate_presence_of(:start_date) }
	it { should validate_presence_of(:deadline) }
	it { should validate_presence_of(:assignment_id) }

	it { should belong_to(:assignment) }
	it { should have_one(:pa_form).dependent(:destroy) }
	it { should have_many(:extensions) }

	it 'validates that start_date is not in the past' do
		iteration  = FactoryGirl.build(:iteration, start_date: DateTime.yesterday)
		expect(iteration.valid?).to be_falsy
		expect(iteration.errors[:start_date][0]).to eq("can't be in the past")
	end

	it 'validates that deadline is not before the start_date' do
		iteration  = FactoryGirl.build(:iteration, start_date: DateTime.tomorrow, deadline: DateTime.yesterday)
		expect(iteration.valid?).to be_falsy
		expect(iteration.errors[:deadline][0]).to eq("can't be before the start_date")
	end
end
