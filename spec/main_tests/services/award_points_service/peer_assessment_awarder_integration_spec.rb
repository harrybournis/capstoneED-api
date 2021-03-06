require 'rails_helper'

RSpec.describe "PeerAssessmentPoints - Integration", type: :request do

  before(:each) do
    host! 'api.example.com'

    @student = create :student_confirmed
    post '/v1/sign_in', params: { email: @student.email, password: '12345678' }
    expect(response.status).to eq(200)
    @csrf = JWTAuth::JWTAuthenticator.decode_token(response.cookies['access-token']).first['csrf_token']

    @student_for = create :student_confirmed
    @student3 = create :student_confirmed
    @assignment = FactoryGirl.create(:assignment)
    @game_setting  = create :game_setting, assignment: @assignment
    @project = FactoryGirl.create(:project, assignment: @assignment)
    @iteration = FactoryGirl.create(:iteration, assignment: @assignment)
    create :students_project, student: @student_for, project: @project
    create :students_project, student: @student3, project: @project
    create :students_project, student: @student, project: @project
    @pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)
  end

  describe 'Success --Student' do

    it 'gets full points for submitting a peer_assessment in time' do
      Timecop.travel(@pa_form.start_date + 1.minute) do
        @student, @csrf = login_integration @student
        expect(PeerAssessmentPoint.where(student_id: @student.id)).to be_empty
        original_points = @student.points_for_project_id(@project.id)

        expect {
          post '/v1/peer_assessments', params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { PeerAssessmentPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment][:id]).count }

        expect(status).to eq 201
        @point = PeerAssessmentPoint.where(student_id: @student.id, peer_assessment_id: body['peer_assessment']['id'], reason_id: Reason[:peer_assessment][:id]).last
        expect(@point.points).to eq @game_setting.points_peer_assessment

        new_points = 0
        PeerAssessmentPoint.where(student_id: @student.id).each do |pap|
          new_points += pap.points
        end
        expect(@student.points_for_project_id(@project.id)).to eq new_points
      end
    end

    it 'gets full points only once (not for every peer assessment) for submitting multiple peer_assessments in time' do
      Timecop.travel(@pa_form.start_date + 1.minute) do
        @student, @csrf = login_integration @student

        @params = { peer_assessments: [
          { pa_form_id: @pa_form.id, submitted_for_id: @student_for.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] },
          { pa_form_id: @pa_form.id, submitted_for_id: @student3.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }
        ]
        }

        expect {
          post '/v1/peer_assessments', params: @params, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { PeerAssessmentPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment][:id]).count }
          .by 1

        expect(status).to eq 201
        expect(body['peer_assessments'].length).to eq 2
      end
    end

    it 'gets full points for submitting a peer_assessment before the rest of the team' do
      Timecop.travel(@pa_form.start_date + 1.minute) do
        @student, @csrf = login_integration @student

        expect {
          post '/v1/peer_assessments', params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { PeerAssessmentPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment_first_of_team][:id]).count }

        expect(status).to eq 201
        @point = PeerAssessmentPoint.where(student_id: @student.id, peer_assessment_id: body['peer_assessment']['id'], reason_id: Reason[:peer_assessment_first_of_team][:id]).last
        expect(@point.points).to eq @game_setting.points_peer_assessment_first_of_team
      end
    end

    it 'awards points for submtting the peer assessment during the first day it is available' do
      Timecop.travel(@pa_form.start_date + 1.minute) do
        @student, @csrf = login_integration @student

        expect {
          post '/v1/peer_assessments', params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { PeerAssessmentPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment_submitted_first_day][:id]).count }

        expect(status).to eq 201
        @point = PeerAssessmentPoint.where(student_id: @student.id, peer_assessment_id: body['peer_assessment']['id'], reason_id: Reason[:peer_assessment_submitted_first_day][:id]).last
        expect(@point.points).to eq @game_setting.points_peer_assessment_submitted_first_day
      end
    end
    # it 'gets less points for submitting a peer_Assessment after others in the team'

    # it 'gets full points for submitting a peer_Assessment before the rest of the assignment students' do
    # Timecop.travel(@pa_form.start_date + 1.minute) do
    # @student, @csrf = login_integration @student
    #
    # expect {
    # post '/v1/peer_assessments', params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }, headers: { 'X-XSRF-TOKEN' => @csrf }
    # }.to change { PeerAssessmentPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment_first_of_assignment][:id]).count }
    #
    # expect(status).to eq 201
    # @point = PeerAssessmentPoint.where(student_id: @student.id, peer_assessment_id: body['peer_assessment']['id'], reason_id: Reason[:peer_assessment_first_of_assignment][:id]).last
    # expect(@point.points).to eq @game_setting.points_peer_assessment_first_of_assignment
    # end
    # end

    # it 'gets less points for submitting a peer_assessment after others in the assignment'
  end

  describe 'Failure --Student' do
    it 'gets no points for not submitting first a peer_assessment in the team' do
      @student3 = create :student_confirmed
      create :students_project, student: @student3, project: @project
      create(:peer_assessment, pa_form: @pa_form, submitted_by: @student_for, submitted_for: @student3)
      create(:peer_assessment, pa_form: @pa_form, submitted_by: @student_for, submitted_for: @student)
      create(:peer_assessment, pa_form: @pa_form, submitted_by: @student3, submitted_for: @student_for)
      create(:peer_assessment, pa_form: @pa_form, submitted_by: @student3, submitted_for: @student)

      Timecop.travel(@pa_form.start_date + 1.minute) do
        @student, @csrf = login_integration @student

        expect {
          post '/v1/peer_assessments', params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to_not change { PeerAssessmentPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment_first_of_team][:id]).count }

        expect(status).to eq 201
        @point = PeerAssessmentPoint.where(student_id: @student.id, peer_assessment_id: body['peer_assessment']['id'], reason_id: Reason[:peer_assessment_first_of_team][:id]).last
        expect(@point).to be_falsy
      end
    end

    it 'does not award points if submitted after the first day available'  do
      Timecop.travel(@pa_form.start_date + 1.day + 1.minute) do
        @student, @csrf = login_integration @student

        expect {
          post '/v1/peer_assessments', params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to_not change { PeerAssessmentPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment_submitted_first_day][:id]).count }

        expect(status).to eq 201
      end
    end

    # it 'gets no points for not submitting first a peer_assessment in the assignment' do
    # @irrelevant_team = create :project, assignment: @assignment
    # @irrelevant_student = create :student_confirmed
    # @irrelevant_student2 = create :student_confirmed
    # create :students_project, student: @irrelevant_student2, project: @irrelevant_team
    # create :students_project, student: @irrelevant_student, project: @irrelevant_team
    # create :peer_assessment, pa_form: @pa_form, submitted_by: @irrelevant_student, submitted_for: @irrelevant_student2
    #
    # Timecop.travel(@pa_form.start_date + 1.minute) do
    # @student, @csrf = login_integration @student
    #
    # expect {
    # post '/v1/peer_assessments', params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }, headers: { 'X-XSRF-TOKEN' => @csrf }
    # }.to_not change { PeerAssessmentPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment_first_of_assignment][:id]).count }
    #
    # expect(status).to eq 201
    # @point = PeerAssessmentPoint.where(student_id: @student.id, peer_assessment_id: body['peer_assessment']['id'], reason_id: Reason[:peer_assessment_first_of_assignment][:id]).last
    # expect(@point).to be_falsy
    # end
    # end
  end

  describe 'Profile points get updated' do

    it 'with points for peer_Assessment, first of team, first of assignment' do
      Timecop.travel(@pa_form.start_date + 1.minute) do
        @student, @csrf = login_integration @student
        expect(@student.points_for_project_id(@project.id)).to eq 0

        expect {
          post '/v1/peer_assessments', params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change {
          @student.points_for_project_id(@project.id)
        }.to(@game_setting.points_peer_assessment +
             @game_setting.points_peer_assessment_first_of_team +
             @game_setting.points_peer_assessment_submitted_first_day)

        expect(status).to eq 201
      end
    end
  end

  describe 'Serialization' do
    it 'includes points in the json response' do
      Timecop.travel(@pa_form.start_date + 1.minute) do
        @student, @csrf = login_integration @student
        expect(@student.points_for_project_id(@project.id)).to eq 0

        expect {
          post '/v1/peer_assessments', params: { pa_form_id: @pa_form.id, submitted_for_id: @student_for.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to change { PeerAssessmentPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment][:id]).count }

        expect(status).to eq 201

        new_points = 0
        PeerAssessmentPoint.where(student_id: @student.id).each do |pap|
          new_points += pap.points
        end
        expect(@student.points_for_project_id(@project.id)).to eq new_points

        expect(body['points']).to be_truthy
        expect(body['points']['points_earned']).to eq new_points
        expect(body['points']['new_total']).to eq @student.points_for_project_id(@project.id)
        expect(body['points']['detailed']['peer_assessment']).to be_a Array
        expect(body['points']['detailed']['peer_assessment'].length).to eq PeerAssessmentPoint.where(student_id: @student.id).count
        expect(body['points']['detailed']['peer_assessment'][0]['reason_id']).to be_truthy
        expect(body['points']['detailed']['peer_assessment'][0]['points']).to be_truthy
      end
    end

    it 'does not include points in the response if the request was invalid' do
      Timecop.travel(@pa_form.start_date + 1.minute) do
        @student, @csrf = login_integration @student

        expect {
          post '/v1/peer_assessments', params: { pa_form_id: @pa_form.id, answers: [{ question_id: 3, answer: 1 }, { question_id: 2, answer: 'I enjoyed the presentations' }] }, headers: { 'X-XSRF-TOKEN' => @csrf }
        }.to_not change { PeerAssessmentPoint.where(student_id: @student.id, reason_id: Reason[:peer_assessment][:id]).count }

        expect(status).to eq 422

        expect(body['points']).to be_falsy
      end
    end
  end
end
