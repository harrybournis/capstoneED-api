# Helper methods for better integrating dry-validations with
# active model.
#
module ValidationHelpers
  extend ActiveSupport::Concern

  # Take the errors from dry-validations Result object,
  # and add them to active model errors.
  #
  # @param key [Symbol] The key that should be used when adding
  #   the error to active model errors.
  # @param errors [Dry::Validation::Result] The result of
  #   validation.
  #
  def result_errors_to_active_model(key, result)
    unless result.success?
      if result.errors.is_a? Array
        result.errors.each do |error|
          errors.add key, error
        end
      else
        result.errors.each do |hash_key, error_hash|
          error_hash.each do |attr, message|
            errors.add key, message[0]
          end
        end
      end
    end
  end
end
