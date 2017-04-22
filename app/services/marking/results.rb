module Marking
  class Results
    def initialize
      @scores = {}
      @marks = {}
    end

    # Returns true if there are marks.
    #
    # @return [Boolean] True if marks is not empty.
    #
    def marked?
      @marks.any?
    end

    # Returns the score for the provided
    # student_id.
    #
    # @param student_id [Integer] The id of the student.
    #
    # @return [Number] The score.
    #
    def score(student_id)
      @scores[student_id]
    end

    # Returns the mark for the provided
    # student_id.
    #
    # @param student_id [Integer] The id of the student.
    #
    # @return [Number] The mark.
    #
    def mark(student_id)
      @marks[student_id]
    end

    # Add a new score for a student_id. Returns nil if
    # student_id already has a score.
    #
    # @param student_id [Integer] The id of the Student
    #   receiving the score.
    # @param score [Integer] The score.
    #
    # @return [Boolean,nil] Returns true if successully added, nil
    #   if the student already has a score.
    #
    def add_score(student_id, score)
      return nil if @scores[student_id]
      @scores[student_id] = score
    end

    # Add a new mark for a student_id. Returns nil if
    # student_id already has a mark.
    #
    # @param student_id [Integer] The id of the Student
    #   receiving the mark.
    # @param score [Integer] The mark.
    #
    # @return [Boolean,nil] Returns true if successully added, nil
    #   if the student already has a mark.
    #
    def add_mark(student_id, mark)
      return nil if @marks[student_id]
      @marks[student_id] = mark
    end
  end
end
