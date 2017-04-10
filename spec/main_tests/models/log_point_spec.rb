require 'rails_helper'

RSpec.describe LogPoint, type: :model do
  subject(:log_point) { build :log_point }
  
  it { should belong_to :project }
  it { should belong_to :students_project }

  it { should validate_presence_of :points }
  it { should validate_presence_of :date }
  it { should validate_presence_of :project_id }

	it 'works' do
		expect(FactoryGirl.create(:log_point)).to be_truthy
	end
end
