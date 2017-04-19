require 'json-schema'

# Contains the available marking algorithms. This module provides an
# interface to the loaded config/marking_algorithms.yml file.
#
# @author [harrybournis]
#
module MarkingAlgorithm
  class Validate
    # Turns the YAML file into json and validates its format. It will
    # throw an exception if the file does not match the defined schema.
    # This will only run once when the file is loaded, and is intended
    # to prevent runtime errors and ensure data integrity as more marking_algorithms
    # are gradually added.
    #
    # The file should contain a 'marking_algorithms' key as the root, and inside
    # it should specify each of the different entries with a UNIQUE integer id.
    # The value attached to each id key should correspond to a class name in the
    # app/services/award/iteration_marking/marking_algorithms folder.
    #
    # @param json [JSON] Should follow the pattern:
    #   "marking_algorithms": {
    #     <integer id>: <class name>
    #   }
    #
    # @example
    #   "marking_algorithms": {
    #     1: WebPaMarkingAlgorithm
    #   }
    #
    # @raise JSON::Schema::ValidationError If the json does not match the schema.
    # @raise IOError if the ids inside each of the entries is not unique.
    #
    def self.validate_schema(json)
      schema = {
        "id" => "http://capstoneed.com/entry-schema#",
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "description" => "Schema for marking_algorithms.yml",
        "type" => "object",
        "properties" => {
          "marking_algorithms" => {
            "patternProperties" => {
              "^[0-9]+$" => {
                "type" => "string" ,
                "uniqueItems" => true
              }
            },
            "additionalProperties" => false
          },
          "required" => "marking_algorithms"
        },
      }

      JSON::Validator.validate!(schema, json)

      # Validates whether the id for each key in the file is unique.
      classes = []
      hashed = JSON.parse(json)
      hashed['marking_algorithms'].keys.each { |key| classes << hashed['marking_algorithms'][key] }
      raise IOError, 'Classes in marking_algorithms.yml are not unique.' unless classes.uniq.length == classes.length
    end
  end

  @marking_algorithms = YAML.load_file(Rails.root.join("config/marking_algorithms.yml")).deep_symbolize_keys

  Validate.validate_schema @marking_algorithms.to_json

  # Returns the id that corresponds to the classname provided.
  #
  # @param id [String] The name of the class.
  #
  # @return [Integer] The id that corresponds to the marking algorithm class.
  #
  def self.id_from_class_name(classname)
    @marking_algorithms[:marking_algorithms].keys.each do |key,val|
      return key[0] if val == classname
    end
  end

  # Returns the classname that corresponds to the id provided.
  # @param key [Integer] The id of the marking algorithm
  #
  # @return [String] The name of the class in string form.
  #
  def self.[](key)
    @marking_algorithms[:marking_algorithms][key]
  end

  # Returns the marking_algorithms.yml file in JSON.
  #
  # @return [JSON] The marking_algorithms.yml file in JSON.
  #
  def self.to_json
    @marking_algorithms.to_json
  end
end
