require 'rails_helper'

RSpec.describe Feeling, type: :model do

	it 'works' do
		expect(FactoryGirl.create(:feeling)).to be_truthy
		expect(FactoryGirl.create(:feeling)).to be_truthy
	end

	it { should validate_presence_of :name }
	it { should validate_uniqueness_of :name }
	it { should validate_presence_of :value }

	it { should validate_inclusion_of(:value).in_range(0..1) } # delete if more descriptive numbers are introduced

	it { should have_many :project_evaluations }
end
