require 'rails_helper'

RSpec.describe Feeling, type: :model do

	it 'works' do
		expect(FactoryBot.create(:feeling)).to be_truthy
		expect(FactoryBot.create(:feeling)).to be_truthy
	end

	it { should validate_presence_of :name }
	it { should validate_uniqueness_of :name }
	it { should validate_presence_of :value }

	it { should validate_inclusion_of(:value).in_array([-1,1]) } # delete if more descriptive numbers are introduced

  it { should have_many(:project_evaluations).through(:feelings_project_evaluations) }
  it { should have_many :feelings_project_evaluations }
end
