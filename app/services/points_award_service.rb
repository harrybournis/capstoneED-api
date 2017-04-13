# The PointsAwardService is responsible for awarding and persisting
# a student's points based on an an action that took place. This
# means initializing the PointsBoard object that will be passed
# between the various awarders/persisters/services/serializers,
# initializing the appropriate Awarder class(es), as well
# initializing the Persister(s). Its role is to coordinate between the
# Awarder, Persister classes, and finally return a PointsBoard
# object with the results.
#
# The user should only have to provide a valid key (as a ruby :symbol),
# supplying a resource object (if applicable to the specific action)
# and receiving a PointsBoard with the results. In case the key is
# invalid, an exception will be thrown.
#
# Extending this service can be accompliced by creating additional
# Awarders (with the proper naming scheme; see Awarder superclass
# for details), and additional/different Persisters. The only
# requirements are that these classes take a PointsBoard in their
# constructor, and return one after calling their #call method.
# After a new Awarder class has been added, it has to be registered in
# the PointsAwardService key/value store.
#
# @author [harrybournis]
#
class PointsAwardService
  include Waterfall

  # Updating this will specify which awarder will be resolved
  # for each key.
  AWARDER_STORE = {
    peer_assessment: 'PeerAssessmentAwarder',
    project_evaluation: 'ProjectEvaluationAwarder',
    log: 'LogAwarder'
  }.freeze

  # Updating this will specify which perister will be resolved
  # for each key.
  PERSISTER_STORE = {
    peer_assessment: 'DefaultPersister',
    project_evaluation: 'DefaultPersister',
    log: 'DefaultPersister',
  }.freeze


  NAMESPACE = "PointsAward".freeze

  attr_reader :awarders, :persisters

  # Returns the keys from the awarder and persister stores.
  #
  # @return [String[]] The keys are Strings.
  #
  def self.keys
    AWARDER_STORE.keys | PERSISTER_STORE.keys
  end

  # Returns true if the key exists in the awarders/persisters store.
  #
  # @param key [Symbol] The key.
  #
  # @return [Boolean]
  #
  def self.key_exists?(key)
    AWARDER_STORE[key] || PERSISTER_STORE[key]
  end

  # Returns the registered awarders for the provided key.
  #
  # @param key [Symbol] The key that will be used to
  #   retrive the appropriate classes.
  #
  # @return [String|String[]] The class(es) that are
  #   registered with this key.
  #
  def self.awarders_for_key(key)
    AWARDER_STORE[key]
  end

  # Returns the registered persisters for the provided key.
  #
  # @param key [Symbol] The key that will be used to
  #   retrive the appropriate classes.
  #
  # @return [String|String[]] The class(es) that are
  #   registered with this key.
  #
  def self.persisters_for_key(key)
    PERSISTER_STORE[key]
  end

  # Constructor. Needs a key and a student and receives
  # an optional resource and options hash. It validates if
  # the AWARDER_STORE and PERSISTER_STORE have the same
  # keys, and throws an exception in case they don't. This
  # is useful in cases where the stores were updated incorrectly.
  #
  # @param key [Symbol] The key that will be used to resolve
  #   the Awarder and Persister classes.
  #
  # @param student [Student] The Student that will be awarded
  #   the points.
  #
  # @param resource = nil [Object] Optional. If there is a resource
  #   connected with the points that will be earned.
  #
  # @param _options = {} [Hash] Arbitrary options hash
  #
  # @return [PointsAwardService] The newly constructed service.
  #   Executes by calling #call on it.
  #
  def initialize(key, student, resource = nil, _options = {})
    validate_stores!
    validate_key! key

    @awarders   = resolve_awarder_classes AWARDER_STORE[key]
    @persisters = resolve_persister_classes PERSISTER_STORE[key]
    @key        = key
    @student    = student
    @resource   = resource

    @points_board = PointsAward::PointsBoard.new(@student, @resource)
  end

  def call
    @awarders.each do |awarder|
      chain(:awarded)   { awarder.new(@points_board).call }
        .when_falsy     { outflow[:awarded].points? }
        .dam            { outflow[:awarded] }
    end

    @persisters.each do |persister|
      chain(:persisted) { persister.new(outflow[:awarded]).call }
        .when_falsy     { outflow[:persisted].persisted? }
        .dam            { outflow[:persisted] }
    end

    chain               { return outflow[:persisted]  }
    on_dam              { return error_pool }
  end

  private

  def validate_stores!
    unless (AWARDER_STORE.keys - PERSISTER_STORE.keys).empty? &&
           (PERSISTER_STORE.keys - AWARDER_STORE.keys).empty?
      raise ArgumentError, I18n.t('errors.points_award.points_award_service.validate_stores')
    end
  end

  def validate_key!(key)
    unless AWARDER_STORE.keys.include? key
      raise ArgumentError, "Invalid Key. Valid Keys are: #{AWARDER_STORE.keys.to_s}"
    end
  end

  def resolve_awarder_classes(string_or_array)
    if string_or_array.is_a? String
      ["#{NAMESPACE}::Awarders::#{string_or_array}".constantize]
    else
      string_or_array.map { |s| "#{NAMESPACE}::Awarders::#{s}".constantize }
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
