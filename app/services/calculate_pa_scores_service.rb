# The CalculatePaScoresService class gives marks to the Students
# of at the end of an Iteration. It takes a completed Iteration,
# checks the submitted peer assessments with a marking algorithm,
# and gives marks to the students according to the settings
# that that the Lecturer specified.
#
# The service is intended to be called by a cron job,
# which checks if an iteration has ended, if it hasn't been
# marked yet, and creates a new CalculatePaScoresService and
# #calls it.
#
# @example
#   service = CalculatePaScoresService.new(@iteration)
#
#   if service.can_mark?
#     service.call
#   end
#
# The method #can_mark will check whether the iteration has
# finished, and whether is has not already been marked.
#
# The CalculatePaScoresService is designed to be extensible, with
# different marking algorithms.
# To define a new marking algorithm, one has to add their class in the
# services/iteration_marking/persisters/ directory, and declare it in the
# marking_algorithms.yml file. Only one marking algorithm may be used
# each time, and the default is the WebPA algorithm. To change the default,
# edit the DEFAULT_MARKING_ALGORITHM constant.
#
# This class can also be extended with multiple persistence options.
# This may be desirable in the case that the marks need to be
# saved in mulitple ways or multiple formats. For example, the marks may
# need to me synced to the university's database or some other centralized
# database. A 'UniversityDatabasePersister' class may be written which
# uses OAuth to login to the University's system, and sends the marks
# in a special form. A different use case could be that the system
# needs to save all the marks in CSV or XML form, and send them by email
# to the Lecturer. Defining persisters allows one, or all of the
# above use cases to be satisfied without them interfering with each other.
#
# @author [harrybournis]
#
class CalculatePaScoresService
  include Waterfall

  attr_reader :marking_klass

  # If no setting is found about the marking, use this class
  DEFAULT_MARKING_ALGORITHM = 'WebPaMarkingAlgorithm'.freeze

  # Add any additional peristers classes in this array.
  PERSISTERS = ['DatabasePersister'].freeze

  # The namespace of where the service's algorithms and
  # persiters live.
  NAMESPACE = 'CalculatePaScores'.freeze

  # Constructor. Takes an iteration to be marked.
  # Resolves the marking_klass and serches the database
  # for the peer assessments of the iteration, and creates
  # the MarkTable object that will be paseed to the
  # marking algorithm.
  #
  # @return [CalculatePaScoresService]
  #
  def initialize(iteration)
    @iteration = iteration
    @marking_klass = resolve_marking_algorithm_class iteration.game_setting.marking_algorithm_id

    pa_form = iteration.pa_form
    @project_marks = []
    iteration.projects.each do |project|
      @pa_answers_tables << CalculatePaScores::PaAnswersTable.new(project, pa_form)
    end
  end

  # Executes the action of the service. Calls the sp
  #
  # @return [type] [description]
  #
  def call
  end

  def can_mark?
    @iteration.finished?
  end

  private

  # Returns the marking algorithm class to be used.
  # It first checks if the provided algorithm_id exists in the
  # available MarkingAlgorithms, and if it can't find one it
  # assigns the DEFAULT_MARKING_ALGORITHM.
  #
  # @param algorithm_id [Integer] The id of the algorithm that should
  #   be resolved.
  #
  # @return [Class]
  #
  def resolve_marking_algorithm_class(algorithm_id)
    if algorithm = MarkingAlgorithm[algorithm_id]
      "Marking::Algorithms::#{algorithm}".constantize
    else
      "Marking::Algorithms::#{DEFAULT_MARKING_ALGORITHM}".constantize
    end
  end

  def resolve_persister_classes(string_or_array)
    if string_or_array.is_a? String
      ["#{NAMESPACE}::Persisters::#{string_or_array}".constantize]
    else
      string_or_array.map { |s| "#{NAMESPACE}::Persisters::#{s}".constantize }
    end
  end
end
