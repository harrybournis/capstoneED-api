require 'rails_helper'

RSpec.describe Unit, type: :model do

	subject(:unit) { FactoryGirl.build(:unit) }

  it { should belong_to(:lecturer) }
  it { should belong_to(:department) }

  it { should validate_presence_of(:name) }
	it { should validate_presence_of(:code) }
  it { should validate_presence_of(:semester) }
  it { should validate_presence_of(:year) }
  it { should validate_presence_of(:lecturer_id) }

  it { should validate_numericality_of(:year) }
end
