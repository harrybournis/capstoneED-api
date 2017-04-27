require 'rails_helper'

RSpec.describe Unit, type: :model do

  subject(:unit) { FactoryGirl.build(:unit) }

  it { should belong_to :lecturer }
  it { should belong_to :department }
  it { should have_many :assignments }
  it { should have_many :projects }

  it { should validate_presence_of :name }
  it { should validate_presence_of :code }
  it { should validate_presence_of :semester }
  it { should validate_presence_of :year }
  it { should validate_presence_of :lecturer_id }

  it { should validate_uniqueness_of(:id) }
  it { should validate_numericality_of(:year) }

  it ".active returns only the non archived units" do
    units = FactoryGirl.create_list(:unit, 4)
    unit = units.first

    unit.archived_at = Date.today
    expect(unit.save).to be_truthy

    expect(Unit.active.count).to eq(3)
  end

  it ".archived returnsl only the archived units" do
    units = FactoryGirl.create_list(:unit, 4)
    unit = units.first

    unit.archived_at = Date.today
    expect(unit.save).to be_truthy

    expect(Unit.archived.count).to eq(1)
  end

  it "#archive sets archived at date" do
    unit = FactoryGirl.create(:unit)

    expect(unit.archived_at).to be_falsy
    expect(unit.archive).to be_truthy
    expect(unit.archived_at).to be_truthy
  end

  it "#archive leads to error if unit has already been archived" do
    unit = FactoryGirl.create(:unit)
    unit.archived_at = Date.today
    expect(unit.save).to be_truthy
    expect(unit.archived?).to be_truthy
    unit.reload

    expect(unit.archive).to be_falsy
    expect(unit.errors[:unit][0]).to include 'has already been archived'
  end

  it '#archived? returns whether a unit is archived' do
    unit = FactoryGirl.create(:unit)

    expect(unit.archived?).to be_falsy

    unit.archive
    unit.reload

    expect(unit.archived?).to be_truthy
  end
end
