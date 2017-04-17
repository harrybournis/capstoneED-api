require 'json-schema'

# Used in conjuction with LogPoints, PeerAssessmentPoints,
# ProjectEvaluationPoints to mark the reason for the points
# being awarded to the student.
#
# Contais a field called 'id' that works as an identifier for
# the source of the points gained. Currently all of the values match
# the game_settings table fields, but this could change in the future,
# adding possible reasons that can not be configured by the Lecturer
# in the game_settings table.
#
# This module provides an interface to the loaded config/reasons.yml file.
# The file is loaded ONCE, and does not get garbage collected.
# This is a case of trading memory usage for less I/O operations,
# and if it proved detrimental comment out the REASON = YAML... line
# and uncomment the comment block in the self.[] method.
#
# @author [harrybournis]
#
module Reason
  class Validate
    # Turns the YAML file into json and validates its format. It will
    # throw an exception if the file does not match the defined schema.
    # This will only run once when the file is loaded, and is intended
    # to prevent runtime errors and ensure data integrity as more reasons
    # are gradually added.
    #
    # The file should contain a 'reasons' key as the root, and inside
    # it should specify each of the different entries with an appropriately,
    # arbitrarily named key. Each entry must contain a unique 'id' of type
    # integer, a required 'description' of type string, and an optional
    # 'message', which contains a human readable message to return to the user.
    #
    # @param json [JSON] Should follow the pattern:
    #   "reasons": {
    #     <reason_key_with_arbitrary_name>: {
    #       "id": <integer>,
    #       "description": <string>,
    #       "message": <string>
    #     }
    #   }
    #
    # @raise JSON::Schema::ValidationError If the json does not match the schema.
    # @raise IOError if the ids inside each of the entries is not unique.
    #
    def self.validate_schema(json)
      schema = {
        "id" => "http://capstoneed.com/entry-schema#",
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "description" => "Schema for reasons.yml",
        "type" => "object",
        "properties" => {
          "reasons" => {
            "patternProperties" => {
              "^.+$" => {
                "properties" => {
                  "id" => {"type" => "integer" , "uniqueItems" => true},
                  "description" => {"type" => "string"},
                  "message" => {"type" => ["string", "null"]}
                },
                "required" => [ "id", "description" ]
              }
            },
            "additionalProperties" => false
          },
          "required" => "reasons"
        },
      }

      JSON::Validator.validate!(schema, json)

      # Validates whether the id for each key in the file is unique.
      ids = []
      hashed = JSON.parse(json)
      hashed['reasons'].keys.each { |key| ids << hashed['reasons'][key]['id'] }
      raise IOError, 'Ids in reasons.yml are not unique.' unless ids.uniq.length == ids.length
    end
  end

  # loads the file as a contstant. Comment out in case of high memory
  # usage. See comment in self.[] method.
  REASONS = YAML.load_file(Rails.root.join("config/reasons.yml")).deep_symbolize_keys

  Validate.validate_schema REASONS.to_json

  # Returns the key that corresponds to the id provided.
  # @param id [Integer] The reason id
  #
  # @return [Symbol] The symbol key that corresponds to the id.
  #
  def self.key_from_id(id)
    REASONS[:reasons].keys.each do |key|
      return key if REASONS[:reasons][key][:id] == id
    end
  end

  def self.[](key)
    REASONS[:reasons][key]

    # !***************************************************************!
    # In case of too high memory usage, use the following. The hash
    # containing the reasons will be garbage collected, and reread from
    # disk on each request that needs to work with awarding points.
    #
    # unless @reasons
    #   @reasons = YAML.load_file(Rails.root.join("config/reasons.yml")).deep_symbolize_keys
    # end
    # @reasons[key]
  end

  def self.to_json
    REASONS.to_json
  end
end
