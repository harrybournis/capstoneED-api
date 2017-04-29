require 'rails_helper'

RSpec.describe Project, type: :model do

  describe 'validations' do
    subject(:project) { FactoryGirl.build(:project) }

    it { should have_many(:students).through(:students_projects).dependent(:delete_all) }
    it { should have_many(:students_projects) }
    it { should have_many(:iterations).through(:assignment) }
    it { should belong_to(:assignment) }
    it { should have_one(:lecturer).through(:assignment) }
    it { should have_one :extension }
    it { should have_many :project_evaluations }
    it { should have_many :peer_assessments }
    it { should belong_to :unit }
    it { should have_many :log_points }
    it { should have_many :peer_assessment_points }
    it { should have_many :project_evaluation_points }
    it { should have_one(:game_setting).through :assignment }

    it { should validate_presence_of :project_name }
    it { should validate_presence_of :assignment }

    it { should validate_uniqueness_of(:id) }
    it { should validate_uniqueness_of(:enrollment_key) }
    it { should validate_uniqueness_of(:project_name).scoped_to(:assignment_id).case_insensitive }

    it 'vaidates uniqueness of team_name for assignment' do
      project = build :project
      expect(project.save).to be_truthy

      # different assignment, same team_name. should be correct
      project2 = build :project, team_name: project.team_name
      expect(project2.save).to be_truthy

      # same assignment, same team_name, should be false
      project3 = build :project, assignment: project.assignment, team_name: project.team_name
      expect(project3.save).to be_falsy
      expect(project3.errors[:team_name][0]).to include('taken')

      # same assignment, same team_name all capitals, should be false
      project4 = build :project, assignment: project.assignment, team_name: project.team_name.upcase
      expect(project4.save).to be_falsy
      expect(project4.errors[:team_name][0]).to include('taken')
    end

    it 'validates presence of team_name' do
      project = create :project
      expect(project.save).to be_truthy

      project.team_name = nil
      expect(project.save).to be_falsy
      expect(project.errors[:team_name][0]).to eq "can't be blank"
    end

    it 'destroys StudentTeams on destroy' do
      assignment = FactoryGirl.create(:assignment_with_projects)
      @project = assignment.projects.first
      2.times { create :students_project, student: create(:student), project: @project }#@project.students << FactoryGirl.create(:student) }
      students_count = Student.all.size
      expect( StudentsProject.all.count).to eq(2)
      expect { Project.destroy(@project.id) }.to change {  StudentsProject.all.count }.by(-2)
      expect(Student.all.size).to eq(students_count)
    end

    it 'before saving gets the unit_id from the assignment' do
      assignment = create :assignment
      project = Project.new(attributes_for(:project, assignment_id: assignment.id).except(:unit_id))
      expect(project.unit_id).to be_falsy

      expect(project.save).to be_truthy

      expect(project.unit).to eq project.assignment.unit
    end

    it 'autogenerates enrollment key if not provided by user' do
      assignment = FactoryGirl.create(:assignment)
      attributes = FactoryGirl.attributes_for(:project).except(:enrollment_key).merge(assignment_id: assignment.id)
      project = Project.new(attributes)
      project.valid?
      expect(project.errors[:enrollment_key]).to be_empty
      expect(project.save).to be_truthy
    end

    it 'does not autogenerate key if provided' do
      assignment = FactoryGirl.create(:assignment)
      attributes = FactoryGirl.attributes_for(:project).merge(assignment_id: assignment.id, enrollment_key: 'key')
      project = Project.new(attributes)
      project.valid?
      expect(project.errors[:enrollment_key]).to be_empty
      expect(project.enrollment_key).to eq('key')
    end

    it 'project_health returns the mean of the iterations_health' do
      assignment = FactoryGirl.create(:assignment)
      2.times { assignment.iterations << FactoryGirl.create(:iteration) }
      project = FactoryGirl.create(:project)
      assignment.projects << project

      iteration1_health = assignment.iterations[0].iteration_health
      iteration2_health = assignment.iterations[1].iteration_health
      expected_health = ((iteration1_health + iteration2_health) / 2).round

      expect(project.project_health).to eq(expected_health)
    end

    it '#student_members returns TeamMember objects with nickname' do
      assignment = FactoryGirl.create(:assignment)
      project = FactoryGirl.create(:project, assignment: assignment)
      student1 = FactoryGirl.create(:student)
      student2 = FactoryGirl.create(:student)

      create :students_project, student: student1, project: project
      create :students_project, student: student2, project: project
      student_members = project.student_members

      student_members.each do |student|
        if student.id == student1.id
          expect(student.email).to eq(student1.email)
          expect(student.nickname).to eq(student1.nickname_for_project_id(project.id))
        end
      end
      project.reload
      expect(student_members.length).to eq(project.students.length)
    end

    describe '.active ' do

      before :each do
        lecturer = create :lecturer
        @unit = create :unit, lecturer: lecturer
        @assignment = create :assignment, unit: @unit, lecturer: lecturer, start_date: DateTime.now, end_date: DateTime.now + 10.days
        3.times { create(:project, unit: @unit, assignment: @assignment) }
        expect(@assignment.projects.count).to eq(3)
        expect(Project.count).to eq(3)
      end

      it 'returns the active projects if unit is not archived' do
        expect(Project.active.count).to eq(3)
        expect(@unit.archive).to be_truthy
        expect(@unit.archived_at).to be_truthy
        expect(Project.active.count).to eq(0)
      end

      it 'returns the active projects if assignment end date has not passed' do
        expect(Project.active.count).to eq(3)

        Timecop.travel(DateTime.now + 20.days) do
          expect(@unit.archived?).to be_falsy
          expect(Project.active.count).to eq(0)
        end
      end
    end


    describe 'autogenerates team_name' do
      it 'if none was given during creation' do
        assignment = create :assignment
        attributes = attributes_for(:project).except(:team_name).merge!(assignment_id: assignment.id)
        expect(attributes[:team_name]).to be_falsy

        project = Project.new(attributes)

        expect(project.save).to be_truthy
        expect(project.team_name).to eq("Team 1")
      end

      it 'assigns the number of the projects in the Assignment' do
        # create first project, which will be called 'Team 1'
        assignment = create :assignment
        attributes = attributes_for(:project).except(:team_name).merge!(assignment_id: assignment.id)

        project = Project.new(attributes)

        expect(project.save).to be_truthy
        expect(assignment.projects.count).to eq(1)
        expect(project.team_name).to eq("Team 1")

        # create second project, which will be called 'Team 2'
        attributes = attributes_for(:project).except(:team_name).merge!(assignment_id: assignment.id)

        project = Project.new(attributes)

        expect(project.save).to be_truthy
        expect(assignment.projects.count).to eq(2)
        expect(project.team_name).to eq("Team 2")

        # create third project, which will be called 'Team 3'
        assignment.reload
        attributes = attributes_for(:project).except(:team_name).merge!(assignment_id: assignment.id)

        project = Project.new(attributes)

        expect(project.save).to be_truthy
        expect(assignment.projects.count).to eq(3)
        expect(project.team_name).to eq("Team 3")
      end
    end

    it '#generate_random_color color generates a new color' do
      project = create :project
      orig_color = project.color

      project.generate_random_color

      expect(project.color).to_not eq orig_color
      expect(project.save).to be_truthy
    end

    it '#team_points returns the total points of all students in project' do
      project = create :project
      student1 = create :student
      student2 = create :student
      points1 = 40
      points2 = 55

      sp1 = create :students_project, student: student1, project: project, points: points1
      sp2 = create :students_project, student: student2, project: project, points: points2
      expect(project.students.count).to eq(2)

      expect(project.team_points).to eq(sp1.points + sp2.points)
    end

    it '#team_points returns 0 if no students in project' do
      expect(project.students.count).to eq(0)

      expect(project.team_points.class).to eq Integer
      expect(project.team_points).to eq 0
    end

    it '#team_average returns the average points of all students in project' do
      project = create :project
      student1 = create :student
      student2 = create :student
      points1 = 40
      points2 = 50

      sp1 = create :students_project, student: student1, project: project, points: points1
      sp2 = create :students_project, student: student2, project: project, points: points2
      expect(project.students.count).to eq(2)

      a = [sp1.points, sp2.points]
      expect(project.team_average.class).to eq Integer
      expect(project.team_average).to eq (a.reduce(:+) / a.size.to_f).round
    end

    it '#team_average returns 0 if no students in project' do
      expect(project.students.count).to eq(0)

      expect(project.team_average.class).to eq Integer
      expect(project.team_average).to eq 0
    end

    it '#current_iteration returns the current iteration' do
      assignment = create :assignment, start_date: DateTime.now, end_date: DateTime.now + 10.days
      project = create :project, assignment: assignment
      current_iteration = create :iteration, assignment: assignment, start_date: DateTime.now, deadline: DateTime.now + 5.days
      other_iteration = create :iteration, assignment: assignment, start_date: DateTime.now + 6.days, deadline: DateTime.now + 9.days
      expect(project.iterations.count).to eq 2

      Timecop.travel DateTime.now + 4.days do
        expect(project.current_iterations.any?).to be_truthy
        expect(project.current_iterations[0]).to eq current_iteration
      end
    end

    it '#current_iteration returns nil if no current iteration' do
      assignment = create :assignment
      project = create :project, assignment: assignment
      other_iteration = create :iteration, assignment: assignment, start_date: DateTime.now + 5.days, deadline: DateTime.now + 10.days

      expect(project.current_iterations.any?).to be_falsy
    end
  end

  describe 'pending_evaluation' do
    before :each do
      @lecturer = create :lecturer_confirmed, id: 1222
      @student = create :student_confirmed
      @unit = create :unit, lecturer: @lecturer
      @assignment = create :assignment, lecturer: @lecturer, unit: @unit, start_date: DateTime.now, end_date: DateTime.now + 11.days
      @project = create :project, assignment: @assignment
      @sp = create :students_project, project: @project, student: @student
      @iteration = create :iteration, assignment: @assignment, start_date: DateTime.now, deadline:  DateTime.now + 10.days
    end

    describe 'returns true' do
      it "when no project_evaluations have been sumbmitted and we are at 40-50\% of the iteration" do
        Timecop.travel DateTime.now + 2.days do
          expect(@project.pending_evaluation(@student)).to be_falsy
        end

        Timecop.travel DateTime.now + 4.days + 5.hours do
          expect(@project.pending_evaluation(@student)).to be_truthy
        end
      end

      it "when no project_evaluations have been sumbmitted and we are at 90-100\% of the iteration" do
        Timecop.travel DateTime.now + 7.days do
          expect(@project.pending_evaluation(@student)).to be_falsy
        end

        Timecop.travel DateTime.now + 9.days + 5.hours do
          expect(@project.pending_evaluation(@student)).to be_truthy
        end
      end

      it 'if 1 has been submitted in the 40-50%, and and we are at 90-100\% of the iteration' do
        Timecop.travel DateTime.now + 4.days + 5.hours do
          expect(@project.pending_evaluation(@student)).to be_truthy
          pe = create :project_evaluation, project: @project, iteration: @iteration, user:  @student
          expect(pe).to be_truthy
        end

        Timecop.travel DateTime.now + 9.days + 5.hours do
          expect(@student.project_evaluations.where(project_id: @project.id, iteration_id: @iteration.id).count).to eq 1
          expect(@project.pending_evaluation(@student)).to be_truthy
        end
      end

      it 'works for lecturer' do
        Timecop.travel DateTime.now + 2.days do
          expect(@project.pending_evaluation(@lecturer)).to be_falsy
        end

        Timecop.travel DateTime.now + 4.days + 5.hours do
          expect(@project.pending_evaluation(@lecturer)).to be_truthy
        end
      end
    end

    describe 'returns false' do
      it 'when max number of project_evaluations has been submitted for this iteration' do
        expect(create :project_evaluation, project: @project, iteration: @iteration, user:  @student).to be_truthy
        expect(create :project_evaluation, project: @project, iteration: @iteration, user:  @student).to be_truthy

        expect(@student.project_evaluations.where(project_id: @project.id, iteration_id: @iteration.id).count).to eq 2
        Timecop.travel DateTime.now + 9.days + 5.hours do
          expect(@project.pending_evaluation(@student)).to be_falsy
        end

        create :iteration, assignment: @assignment, start_date: DateTime.now + 10.days + 10.hours, deadline: DateTime.now + 10.days + 15.hours

        Timecop.travel DateTime.now + 10.days + 12.hours do
          expect(@project.pending_evaluation(@student)).to be_truthy
        end
      end

      it "if 1 has been submitted, and and we are at 40-50\% of the iteration" do
        Timecop.travel DateTime.now + 4.days + 5.hours do
          pe = create :project_evaluation, project: @project, iteration: @iteration, user:  @student
          expect(pe).to be_truthy
        end

        Timecop.travel DateTime.now + 4.days + 7.hours do
          expect(@student.project_evaluations.where(project_id: @project.id, iteration_id: @iteration.id).count).to eq 1
          expect(@project.pending_evaluation(@student)).to be_falsy
        end
      end

      it "if 1 has been submitted in the 90-100\%, and we are at the 90-100%" do
        Timecop.travel DateTime.now + 9.days + 5.hours do
          pe = create :project_evaluation, project: @project, iteration: @iteration, user:  @student
          expect(pe).to be_truthy
        end

        Timecop.travel DateTime.now + 9.days + 7.hours do
          expect(@student.project_evaluations.where(project_id: @project.id, iteration_id: @iteration.id).count).to eq 1
          expect(@project.pending_evaluation(@student)).to be_falsy
        end
      end

      it 'when the student is not a member of the project' do
        assignment = create :assignment
        iteration = create :iteration, assignment: @assignment, start_date: DateTime.now, deadline:  DateTime.now + 10.days
        project2 = create :project, assignment: assignment

        expect(project2.pending_evaluation(@student)).to be_falsy
      end

      it 'when the project has no active iterations' do
        assignment = create :assignment
        iteration = create :iteration, assignment: assignment, start_date: DateTime.now + 2.days, deadline:  DateTime.now + 10.days
        project2 = create :project, assignment: assignment
        sp = create :students_project, project: project2, student: @student

        expect(project2.pending_evaluation(@student)).to be_falsy
      end

    end
  end
end


