require 'rails_helper'

RSpec.describe Student, type: :model do

	describe 'validations' do
		subject(:student) { build(:student) }

		it { should have_many(:projects).through(:students_projects) }
		it { should have_many(:assignments).through(:projects) }
		it { should have_many(:peer_assessments_submitted_by) }
		it { should have_many(:peer_assessments_submitted_for) }
		it { should have_one :student_profile }
    it { should have_many :iteration_marks }

		it { should validate_presence_of :first_name }
		it { should validate_presence_of :last_name }
		it { should validate_presence_of :email }

		it { should validate_absence_of :position }
		it { should validate_absence_of :university }

		it { should validate_uniqueness_of(:id) }
		it { should validate_uniqueness_of(:email).case_insensitive }

		it { should validate_confirmation_of(:password) }

		it 'does not allow provider to be updated' do
			student = create(:student)
			expect(student.update(provider: 'email')).to be_truthy
			expect(student.errors).to be_empty
			expect(student.provider).to eq('test')
		end
	end

	let(:student) { create(:student) }

	it 'destroys students_projects on destroy' do
		assignment = create(:assignment_with_projects)
		@project = assignment.projects.first
		student = create(:student)
		#@project.students << student
		create :students_project, student: student, project: @project
		team_count = Project.all.size
		expect( StudentsProject.all.count).to eq(1)
		expect { student.destroy }.to change {  StudentsProject.all.count }.by(-1)
		expect(Project.all.size).to eq(team_count)
	end

	it '#teammates returns students in the same projects' do
		@user = create(:student_confirmed)

		project1 = create(:project)
		project3 = create(:project)
		teammate = create(:student_confirmed)
		3.times { create :students_project, student: create(:student_confirmed), project: project1 }#project1.students << create(:student_confirmed) }
		create :students_project, student: @user, project: project1
		create :students_project, student: teammate, project: project1
		3.times { create :students_project, student: create(:student_confirmed), project: project3 } #project3.students << create(:student_confirmed) }
		create :students_project, student: @user, project: project3
		create :students_project, student: teammate, project: project3

		expect(@user.projects.length).to eq 2
		expect(@user.teammates.length).to eq 7
	end

	it '#teammates returns students and includes the students if passed true' do
		@user = create(:student_confirmed)

		project1 = create(:project)
		project3 = create(:project)
		teammate = create(:student_confirmed)
		3.times { create :students_project, student: create(:student_confirmed), project: project1 }#project1.students << create(:student_confirmed) }
		create :students_project, student: @user, project: project1
		create :students_project, student: teammate, project: project1
		3.times { create :students_project, student: create(:student_confirmed), project: project3 } #project3.students << create(:student_confirmed) }
		create :students_project, student: @user, project: project3
		create :students_project, student: teammate, project: project3

		expect(@user.projects.length).to eq 2
		expect(@user.teammates(true).length).to eq 8
		expect(@user.teammates).to_not include @user
		expect(@user.teammates(true)).to include @user
	end

	it '#nickname_for_project_id returns the nickname for the provided project' do
		student = create(:student)
		project = create(:project)
		project2 = create(:project)
		nickname = "dr dre"
		nickname2 = "snoop dogg"
		sp =  StudentsProject.new(project_id: project.id, student_id: student.id, nickname: nickname)
		sp2 =  StudentsProject.new(project_id: project2.id, student_id: student.id, nickname: nickname2)

		expect(sp.save).to be_truthy
		expect(student.nickname_for_project_id(project.id)).to eq(nickname)
		expect(sp2.save).to be_truthy
		expect(student.nickname_for_project_id(project2.id)).to eq(nickname2)
	end

	it '#nickname_for_project_id returns nil if student is not in the project' do
		student = create(:student)
		project = create(:project)

		expect(student.nickname_for_project_id(project.id)).to eq(nil)
	end

	it '#points_for_project_id returns the points for the provided project' do
		student = create(:student)
		project = create(:project)
		project2 = create(:project)
		nickname = "dr dre"
		nickname2 = "snoop dogg"
		points1 = 30
		points2 = 50
		sp =  StudentsProject.new(project_id: project.id, student_id: student.id, nickname: nickname, points: points1)
		sp2 =  StudentsProject.new(project_id: project2.id, student_id: student.id, nickname: nickname2, points: points2)

		expect(sp.save).to be_truthy
		expect(student.points_for_project_id(project.id)).to eq(points1)
		expect(sp2.save).to be_truthy
		expect(student.points_for_project_id(project2.id)).to eq(points2)
	end

	it '#points_for_project_id returns nil if student is not in the project' do
		student = create(:student)
		project = create(:project)

		expect(student.points_for_project_id(project.id)).to eq(nil)
	end

	it '#add_points_for_project_id returns the updated points for the project' do
		student = create :student_confirmed
		project = create :project
		project2 = create :project
		points1 = 30
		points2 = 50
		sp =  StudentsProject.new(project_id: project.id, student_id: student.id, nickname: 'nickanem', points: points1)
		sp2 =  StudentsProject.new(project_id: project2.id, student_id: student.id, nickname: 'nicknens', points: points2)

		expect(sp.save).to be_truthy
		expect(student.add_points_for_project_id(20, project.id)).to eq(points1 + 20)
		expect(sp2.save).to be_truthy
		expect(student.add_points_for_project_id(10, project2.id)).to eq(points2 + 10)
	end
	it '#add_points_for_project_id returns nil if student not in the project' do
		student = create(:student)
		project = create(:project)

		expect(student.add_points_for_project_id(20, project.id)).to eq(nil)
	end

  it 'total_xp returns the total xp from the student_profile' do
    xp = 90
    sp = create :student_profile, total_xp: xp

    expect(sp.student.total_xp).to eq sp.total_xp
  end

  it 'level returnst he level from the student_profile' do
    level =4
    sp = create :student_profile, level: 4

    expect(sp.student.level).to eq sp.level
  end
end
