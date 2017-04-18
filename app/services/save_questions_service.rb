# Takes a hash of questions, and saves them in the database.
# Called after the successuful creation of a PaForm.
# Checks whether the text of a question already exists
# in the database, and if it doesn't it creates a new
# record for the particular lecturer.
#
# This action is encapsulated in this service since it
# can get more advanced and complicated in the future.
# It currently simply checks the text of equality,
# alhtough the checks could become smarter in the future
# through the use of fuzzy text matching. Α question
# may also acquire more attributes and relations in the
# future, so keeping its creation logic encapsulated within
# this class makes sense.
#
# @author [harrybournis]
#
class SaveQuestionsService
  # Constructor. Needs a hash of questions (an array of hashes with
  # a key called 'text' inside) and a lecturer_id.
  #
  # @param questions_hash [Array<Hash>] An Array of Hashes. Each hash
  #   must have a 'text' key-value.
  # @param lecturer_id [Integer] The id of the lecturer that
  #   created the form.
  #
  # @return [SaveQuestionsService]
  #
  def initialize(questions_hash, lecturer_id)
    if questions_hash.is_a?(Array)

      questions_hash.each do |q|
        @questions_hash = nil unless q['text']
      end
      @questions_hash = questions_hash
    else
      @questions_hash = nil
    end

    @lecturer_id = lecturer_id
  end

  # Parses the questions_hash and saves the
  # appropriate questions in the database.
  # Returns true if successful or false if there
  # was an error.
  #
  # @return [Boolean] Returns true if saved successfully
  #
  def call
    return false unless @questions_hash && @lecturer_id

    @questions_hash.each do |q|
      unless Question.find_by(lecturer_id: @lecturer_id, text: q['text'])
        new_question = Question.new lecturer_id: @lecturer_id, text: q['text']
        return false unless new_question.save
      end
    end
  end
end
