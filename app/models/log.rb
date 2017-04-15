# A student can submit many logs for a project.
# This class is not an ActiveRecord model, since logs are currently
# implemented and saved in the JoinTables::StudentsProject model.
# This class is meant to provide some abstraction from that implementation,
# and increase maintainability of the project. Having a separate model for
# logs also makes JSON serialization easier.
#
# This class takes care of persisting a log entry, and shares a similar api
# with active record models, only it will create records in the
# students_projects table. It also does not have an id, due to the current
# logs implementation not having one.
#
# @!attribute project_id
#   @return [Integer] The id of the project for this log.
#
# @!attribute student_id
#   @return [Integer] The id of the student submitting the log.
#
# @!attribute date_worked
#   @return [Integer] The date the at the student did the work that the are logging.
#     In Unix time.
#
# @!attribute time_worked
#   @return [Integer] The date the at the student spent working. In Unix time.
#
# @!attribute date_submitted
#   @return [Integer] The date that the log was submitted Autocompleted by the
#     system on submission. In Unix time.
#
# @!attribute stage
#   @return [String] The stage of the project in which the work referes to.
#     Example: Analysis, Design, Implementation
#
# @!attribute text
#   @return [String] The content of the log entry. Free form text.
#
# @author [harrybournis]
#
class Log
  include ActiveModel::Serialization

  attr_reader :student_id, :project_id, :date_worked, :date_submitted,
              :time_worked, :stage, :text, :students_project

  # Constructor. Takes a hash of the log entry, the students_project object
  # and a third optional parameter which indicates whether it is a new
  # record or an existing one.
  #
  # @param entry [Hash] A hash with the required parameters for the log.
  # @option project_id [Integer] The id of the project for this log.
  # @option student_id The id of the student submitting the log.
  # @option date_worked [Integer] The date the at the student did the work that the are logging.
  #   In Unix time.
  # @option time_worked [Integer] The date the at the student spent working. In Unix time.
  # @option date_submitted [Integer] The date that the log was submitted Autocompleted by the
  #   system on submission. In Unix time.
  # @option stage [String] The stage of the project in which the work referes to.
  #   Example: Analysis, Design, Implementation
  # @option stage [String] The stage of the project in which the work referes to.
  #   Example: Analysis, Design, Implementation
  #
  # @param students_project [StudentsProject] The students_object project
  # @param persisted = false [Boolean] Whether the record is a new record that
  #   should be saved, or an existing record from the database.
  #
  # @return [Log]
  #
  def initialize(entry, students_project, persisted = false)
    @entry = entry
    @project_id = students_project.project_id
    @student_id = students_project.student_id
    @date_worked = entry['date_worked']
    @date_submitted = entry['date_submitted']
    @time_worked = entry['time_worked']
    @stage = entry['stage']
    @text = entry['text']
    @students_project = students_project
    @persisted = persisted

    @errors = []
  end

  # Saves the log in the students_project passed during
  # initialization. Sets the date_submitted attribute before saving.
  # The validation happens on the students_project model.
  # If persisted is set to true it will return false.
  # If saving is unsuccessful, it will add the errors form the
  # students_project in the errors array before returning false.
  #
  # @return [Log | False] Returns log if successfully saved, or false
  #
  def save
    if @persisted
      @errors << 'Record has already persisted'
      return false
    end

    time_now = DateTime.now.to_i.to_s
    @students_project.logs << if @entry.class == Hash
                                @entry.merge('date_submitted' => time_now)
                              else
                                []
                              end
    if @students_project.save
      persisted!
      @date_submitted = time_now
      return self
    end

    @errors = @students_project.errors
    false
  end

  # Returns the errors array.
  #
  # @return [Array] The errors
  #
  def errors
    @errors
  end

  # Returns the project that the log was for.
  #
  # @return [Project] The project.
  #
  def project
    @students_project.project
  end

  # Returns the student that submitted the log.
  #
  # @return [Student] The Student that submitted the log.
  #
  def student
    @students_project.student
  end

  # Returns true if the errors array is empty.
  #
  # @return [Boolean]
  #
  def valid?
    @errors.empty?
  end

  # Returns true if the record has persisted.
  #
  # @return [Boolean]
  #
  def persisted?
    @persisted
  end

  private

  def persisted!
    @persisted = true
  end
end
