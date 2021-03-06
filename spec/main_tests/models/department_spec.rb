require 'rails_helper'

RSpec.describe Department, type: :model do

	it { should have_many(:units) }

	it { should validate_presence_of(:university) }
	it { should validate_presence_of(:name) }

	it { should validate_uniqueness_of(:id) }
	#it { should validate_uniqueness_of(:name).scoped_to(:university).with_message('this department already exists for this University').case_insensitive }

	# it 'should validate iniqueness of name for each university' do
	# 	uni 	= 'Harvard'
	# 	dep_name	= 'Computer Science'
	# 	department = FactoryGirl.create(:department, { university: uni, name: dep_name })
	# 	expect(department.valid?).to be_truthy

	# 	department2 = FactoryGirl.build(:department, { university: uni, name: dep_name })
	# 	expect(department2.valid?).to be_falsy
	# 	expect(department2.errors[:name].first).to eq('this department already exists for this University')

	# 	department3 = FactoryGirl.build(:department, { university: uni, name: 'Psychology' })
	# 	expect(department3.valid?).to be_truthy

	# 	department4 = FactoryGirl.build(:department, { university: 'Yale', name: dep_name })
	# 	expect(department4.valid?).to be_truthy
	# end
end
