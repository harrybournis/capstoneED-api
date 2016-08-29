require 'rails_helper'

RSpec.describe Student, type: :model do

	describe 'validations' do
		subject(:student) { FactoryGirl.build(:student) }

		it { should have_many(:teams).through(:students_teams) }

		it { should validate_presence_of(:first_name) }
		it { should validate_presence_of(:last_name) }
		it { should validate_presence_of(:email) }

		it { should validate_uniqueness_of(:id) }
		it { should validate_uniqueness_of(:email).case_insensitive }

		it 'does not allow provider to be updated' do
			student = FactoryGirl.create(:student)
			expect(student.update(provider: 'email')).to be_truthy
			expect(student.errors).to be_empty
			expect(student.provider).to eq('test')
		end
	end

	let(:student) { FactoryGirl.create(:student) }

	it 'should not allow university or position to be assigned a value' do
		student.university = 'New university'
		student.position = 'Professor'
		expect(student.university).to be_falsy
		expect(student.position).to be_falsy

		student = Student.new(FactoryGirl.attributes_for(:student).merge({ position: 'Professor', university: 'Harvard' }) )
		expect(student.valid?).to be_truthy
		expect(student.university).to be_falsy
		expect(student.position).to be_falsy
	end


end
