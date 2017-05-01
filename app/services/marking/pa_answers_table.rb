# Module for marking an iteration for Peer Assessments.
#
# @author [harrybournis]
#
module Marking
  # A project mark table contains the points in a 'table-like' format
  # with the marks that each student gave to their teammate for
  # each question of the peer assessment. It does not inlcude
  # questions that require 'text' as their output, as they can not
  # be marked with current grading algorithms.
  #
  # This class' responsibility is to retrieve the peer assessment
  # data from the database, and to abstract its format from the
  # marking algorithms. If the storage medium changes, this class
  # should be editted to ensure that it retrieves the data in a
  # correct way.
  #
  # @author [harrybournis]
  #
  class PaAnswersTable
    attr_reader :project, :student_ids, :pa_form, :question_ids
    # Constructor. Creates a new PaAnswersTable for an Project and
    # a PaForm. Gets peer assessments from the database for this
    # pa_form, and creates the marks array. For every peer
    # assessment that is missing, it puts zero as a mark in
    # the table.
    #
    # @param project [Project] A Project that will be marked
    # @param pa_form [PaForm] The PaForm that the Project will be
    #   marked for.
    #
    # @return [PaAnswersTable]
    #
    def initialize(project, pa_form)
      @project = project
      @pa_form = pa_form
      @valid_question_types = QuestionType.select(:id).where.not(category: 'text').ids

      # Get all the question_ids that are the same type as the valid_question_types and
      # they can be marked.
      @question_ids = []
      @pa_form.questions.each.with_index do |q,index|
        @question_ids << q['question_id'] if @valid_question_types.include? q['type_id']
      end

      @peer_assessments = @pa_form.peer_assessments.where(project_id: @project.id)

      @student_ids = @project.students.select(:id).ids
      # get the ids of the students that did not submit, if any
      @did_not_submit = Student.find_by_sql([
                        %{
                          select users.id from users
                          inner join students_projects
                          on users.id = students_projects.student_id
                          where users.type = 'Student'
                          and students_projects.project_id = :project_id
                          and users.id not in
                          (
                              select peer_assessments.submitted_by_id from peer_assessments
                              where peer_assessments.project_id = :project_id
                          )
                        }, project_id: @project.id])
      @table = init_table
    end

    # Get the marks for a question id.
    #
    # @param question_id [Integer] The question_id
    #
    # @return [Hash]
    #
    def [](question_id)
      @table[question_id]
    end

    def everyone_submitted?
      @did_not_submit.empty?
    end

    # Returns an array of the the marks that a student awarded to
    # other students for a question.
    # Conceptually, a 'row' from the table.
    #
    # @param student_id [Integer] The id of the student.
    # @param question_id [Integer] The id of the question.
    #
    # @return [Array<Integer>] An Array of marks
    #
    def awarded_by(student_id, question_id)
      temp = []
      @table[question_id][student_id].each do |awarded_for,mark|
        temp << mark
      end
      temp
    end

    # Returns an array of the the marks that a student received
    # for a question.
    # Conceptually, a 'column' from the table.
    #
    # @param student_id [Integer] The id of the student.
    # @param question_id [Integer] The id of the question.
    #
    # @return [Array<Integer>] An Array of marks
    #
    def received_by(student_id, question_id)
      temp = []
      @table[question_id].each do |awarded,received|
        temp << received[student_id]
      end
      temp
    end

    # Returns the mark that a student awarded to
    # another student for question.
    #
    # @param awarder_id [Integer] The id of the
    # student awarding the mark.
    # @param receiver_id [Integer] The id of the
    # student receiving the mark.
    # @param question_id [Integer] The if of the
    # question.
    #
    # @return [Integer] The mark.
    #
    def by_for(awarder_id, receiver_id, question_id)
      @table[question_id][awarder_id][receiver_id]
    end

    # Returns an Array with the ids of the
    # Students that did not submit the Peer Assessment.
    #
    # @return [Array<Integer>] The ids of the students
    #   that did not submit.
    def did_not_submit_ids
      @did_not_submit.map(&:id)
    end

    private

    # Retrieves peer assessments from the database,
    # and format collects them by question. The hash
    # it returns has the follwing structure:
    #
    #   {
    #     question_id_1: {
    #       submitted_by_id_1: {
    #         submitted_for_id_1: mark_for_question_1,
    #       },
    #       submitted_by_id_2: {
    #         submitted_for_id_2: mark_for_question_1,
    #       }
    #     },
    #     question_id_2: {
    #       submitted_by_id_1: {
    #         submitted_for_id_1: mark_for_question_2,
    #       },
    #       submitted_by_id_2: {
    #         submitted_for_id_2: mark_for_question_2,
    #       }
    #     }
    #   }
    #
    # @return [Hash] A hash containing the marks
    #   each student gave to the others organized by
    #   question and the student who submitted it.
    #
    def init_table
      # create a triple nested hash with other hashes
      # as default values
      @table = Hash.new do |key,val|
        key[val] = Hash.new { |k,v| k[v] = {} }
      end

      @peer_assessments.each do |pa|
        pa.answers.each do |answer|
          q_id = answer['question_id']
          next unless @question_ids.include?(q_id)
          @table[q_id][pa.submitted_by_id][pa.submitted_for_id] = answer['answer']
        end
      end

      # add zeros for marks if a student did not
      # submit.
      unless everyone_submitted?
        @project.students.each do |s|
          @question_ids.each do |q_id|
            @did_not_submit.each do |did_not|
              @table[q_id][did_not.id][s.id] = 0
            end
          end
        end
      end

      @table
    end
  end
end
