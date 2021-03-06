module PointsAward
  # Wraps the points awarded to a Student for performing an action,
  # and provides a common interface between the various components
  # of the AwardPoints Service. Can return the points in a hash.
  #   {
  #      peer_assessment: [{ points_id: 10, reason: 5, resource_id: 4 },
  #                        { points_id: 50, reason: 1, resource_id: 6 }],
  #      log: [{ points_id: 40, reason: 8, resource_id: 8 },
  #            { points_id: 5, reason: 3, resource_id: 2 }],
  #      project_evaluation: [{ points_id: 40, reason: 8, resource_id: 8 },
  #                           { points_id: 5, reason: 3, resource_id: 2 }]
  #   }
  #
  # It validates the format of the points before adding them to the points hash.
  # It also keeps an errors hash.
  #
  # @author [harrybournis]
  #
  class PointsBoard < ActiveModelSerializers::Model
    attr_reader :student, :resource, :points, :points_persisted, :errors
    attr_accessor :xp

    # Constructor. Takes a Student object which will be awarded the points,
    # and an optional resource.
    #
    # @param student [Student] The Student that will be awarded the points.
    # @param resource [Object] Optional. The resource that triggered the
    #   points awarding.
    # @param _options [Hash] Optional. An arbitrary number of options in a hash.
    #
    # @raise [TypeError] if the params supplied do not match the specified
    #   types.
    #
    # @return [AwardPoints::PointsBoard] A new PointsBoard object.
    #
    def initialize(student, resource = nil, _options = {})
      @student = student
      @resource = resource
      @persisted = false
      @points = {}
      @errors = {}
      @xp = nil
      @points_persisted = []
    end

    # Helper method to delegate the key to the points hash.
    #
    # @param value [Sybmol] The key will be used to retrieve
    #   the from the points hash.
    #
    # @return [Array<Hash>] The array of points for the key
    #   provided.
    #
    def [](value)
      @points[value]
    end

    # Returns the sum of all the points in the array. If an optional
    # key is provided, then the sum is returned only for that key in the hash.
    #
    # @param key [Symbol] Optional. Sums up the points only for that key.
    #
    # @raise [ArgumentError] Raises error if the key can not be found in the
    #   points hash.
    #
    # @return [Integer]
    #
    def total_points(key = nil)
      result = 0
      sum = ->(e) { result += e[:points] }

      if key
        raise ArgumentError, 'Key does not exist in hash' unless @points.keys.include?(key)
        @points[key].each(&sum)
      else
        @points.keys.each { |k| @points[k].each(&sum) }
      end
      result
    end

    # Returns true if there were errors in saving the records.
    #
    # @return [Boolean]
    #
    def errors?
      @errors.any?
    end

    # Returns true if there are any points in the points hash.
    #
    # @return [Boolean]
    #
    def points?
      @points.any?
    end

    # Sets @persisted to true. Used as a flag after successfully
    # saving the points into permanent storage.
    #
    # @return [Boolean]
    #
    def persisted!
      @persisted = true
    end

    # Returns true if the points have already been persisted in storage.
    #
    # @return [Boolean]
    #
    def persisted?
      @persisted
    end

    # Returns true if the records have persisted and there are no errors.
    #
    # @return [Boolean]
    #
    def success?
      !errors?
    end

    # Sets the points_persisted attrbibute if the PointsBoard has persisted!.
    # Returns false if it has not persisted.
    #
    # @param array [PeerAssessmentPoint[] | ProjectEvaluationPoint[] | LogPoint[]]
    #   An Array of PeerAssessmentPoint, ProjectEvaluationPoint and LogPoint objects
    #
    # @raise ArgumentError If The input is not an Array.
    #
    # @return [Boolean] True if the PointsBoard has persisted, false otherwise.
    #
    def points_persisted=(array)
      return false unless @persisted
      raise ArgumentError, 'Input is not an array.' unless array.is_a? Array
      @points_persisted = array
      true
    end

    # Adds new poits to the points hash, using the 'key' param as key.
    # The provided hash is validated for the correct format, and is then
    # added to the underlying array. An exception will be raised if the
    # key is not a symbol, and if required parameters are missing from
    # the hash.
    #
    # @param key [Symbol] The key that the provided hash will be stored
    #   under in the points hash.
    #
    # @param hash [Hash] The hash containing the points, the reason and
    #   an optional resource_id.
    # @option points [Integer] The number of points that have been awarded.
    # @option reason_id [Integer] The reason for awarding the points. Maps to
    #   Reasons model value enum field.
    # @option resource_id [Integer] Optional. The resource (log,
    #   peer assessment, project evaluation) that was created that led
    #   to the Student being awarded points.
    #
    # @example
    #   @points_board.add(:peer_assessment, { points_id: 30, reason_id: 4, resource_id: 7 })
    #
    # @raise [ArgumentError] if the key is not a Symbol, or the hash does
    #   not contain the values 'points' and 'reason_id'
    #
    # @return [PointsBoard] Returns itself to possibly chain add methods.
    #
    def add(key, hash)
      raise ArgumentError, 'Key must be a symbol' unless key.is_a?(Symbol)
      raise ArgumentError, "Points hash can't be nil" if hash.nil?
      unless (res = validate_points_hash(hash)).success?
        raise ArgumentError, 'Invalid hash fields.'
      end

      @points[key] ? @points[key] << res.output : @points[key] = [res.output]
    end

    # Adds an error string in the errors hash using the key provided.
    # Raises an exception if the key is not a symbol, or if the
    # error string is not a String.
    #
    # @param key [Symbol] The key that will be used to add the error into the
    #   errors hash.
    # @param error [String] The error that will be added. Must be a String.
    #
    # @raise [ArgumentError] If the key is not a Sybmol
    # @raise [ArgumentError] If the error is not a String
    #
    def add_error(key, error)
      raise ArgumentError unless key.is_a?(Symbol)
      raise ArgumentError, 'Error must be a String.' unless error.is_a? String

      @errors[key] ? @errors[key] << error : @errors[key] = [error]
    end

    private

    # Validates a points hash with a schema. The hash must contain three keys:
    # :points, :reason_id, :resource_id. The validation schema will be returned
    # which contains both the result of the validation, and the original hash.
    #
    # @example
    #   { points_id: 30, reason_id: 4, resource_id: 7 }
    #
    # @param hash [Hash] The hash containing the points, the reason and
    #   an optional resource_id.
    # @option points [Integer] The number of points that have been awarded.
    # @option reason_id [Integer] The reason for awarding the points. Maps to
    #   Reasons model value enum field.
    # @option resource_id [Integer] Optional. The resource (log,
    #   peer assessment, project evaluation) that was created that led
    #   to the Student being awarded points.
    #
    # @return [Dry::Validation::Result] The result of the validation. See
    #   dry-validations gem documentation.
    #
    def validate_points_hash(hash)
      schema = Dry::Validation.Schema do
        configure { config.input_processor = :form }

        required(:points).value(:int?)
        required(:reason_id).value(:int?)
        optional(:resource_id).value(:int?)
      end

      schema.call(hash)
    end
  end
end
