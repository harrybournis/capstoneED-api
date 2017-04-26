require 'rails_helper'

RSpec.describe FormTemplate, type: :model do
  subject(:form_template) { FactoryGirl.build(:form_template) }

  it { should belong_to :lecturer }
  it { should validate_presence_of :name }
  it { should validate_presence_of :questions }
  it { should validate_presence_of :lecturer }

  it 'works' do
    expect(create(:form_template)).to be_truthy
  end
end
