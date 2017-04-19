require 'rails_helper'
require 'timecop'

RSpec.describe Iteration, type: :model do
	subject(:iteration) { create(:iteration) }

	it { should validate_presence_of(:name) }
	it { should validate_presence_of(:start_date) }
	it { should validate_presence_of(:deadline) }
	it { should validate_presence_of(:assignment) }

	it { should belong_to(:assignment) }
	it { should have_one(:pa_form).dependent(:destroy) }
	it { should have_many(:extensions) }
	it { should have_many :project_evaluations }
	it { should have_many(:peer_assessments).through(:pa_form) }
	it { should have_one(:game_setting).through(:assignment) }

	it '#active? returns whether the iteration is currently going on' do
		now = DateTime.now
		assignment = create :assignment
		iteration = create :iteration, assignment: assignment

		Timecop.travel iteration.start_date + 2.hours do
			expect(iteration.active?).to be_truthy
		end

		Timecop.travel(DateTime.now + 1.year) do
			expect(iteration.active?).to be_falsy
		end
	end

	it '#finished? returns true if the iteration deadline has passed' do
		expect(iteration = create(:iteration)).to be_truthy

		Timecop.travel iteration.start_date + 1.day do
			expect(iteration.finished?).to be_falsy
		end

		Timecop.travel iteration.deadline + 1.day do
			expect(iteration.finished?).to be_truthy
		end
	end

	it 'validates that start_date is not in the past' do
		iteration  = build(:iteration, start_date: DateTime.yesterday)
		expect(iteration.valid?).to be_falsy
		expect(iteration.errors[:start_date][0]).to eq("can't be in the past")
	end

	# it 'validates that start_date is not in the past' do
	# 	iteration  = FactoryGirl.build(:iteration, start_date: DateTime.yesterday)
	# 	expect(iteration.valid?).to be_falsy
	# 	expect(iteration.errors[:start_date][0]).to eq("can't be in the past")
	# end

	it 'validates that deadline is not before the start_date' do
		iteration  = build(:iteration, start_date: DateTime.tomorrow, deadline: DateTime.yesterday)
		expect(iteration.valid?).to be_falsy
		expect(iteration.errors[:deadline][0]).to eq("can't be before the start_date")
	end

	it 'validates that the iteration must be between assignment start_date and end_date' do
		now = DateTime.now
		assignment = create :assignment, start_date: now, end_date: now + 10.days

		iteration = build :iteration, assignment: assignment, start_date: now, deadline: now + 11.days
		expect(iteration.valid?).to be_falsy
		expect(iteration.errors[:deadline]).to be_truthy

		iteration = build :iteration, assignment: assignment, start_date: now - 1.day, deadline: now + 9.days
		expect(iteration.valid?).to be_falsy
		expect(iteration.errors[:start_date]).to be_truthy

		iteration = build :iteration, assignment: assignment, start_date: now + 1.day, deadline: now + 9.days
		expect(iteration.valid?).to be_truthy

		iteration = build :iteration, assignment: assignment, start_date: now, deadline: now + 10.days
		expect(iteration.valid?).to be_truthy
	end

  it '#evaluation_submission_period_middle returns the range between the dates in 40-50% of the iteration length' do
  end

  it '#evaluation_submission_period_end returns the range between the dates in 90-100% of the iteration length' do
  end
end
