# Helpers for rendering responses in JSON.
#
# @author [harrybournis]
#
module ApiHelper
    # Specifies the format the errors should have
    # in invalid responses.
    # @param errors [Hash] An errors hash, either
    # from an active record object or custom.
    #
    # @return [Hash] Returns the errors in a formatted
    #   hash, which will be then serialized into JSON
    #   by the controller.
    #
  def format_errors(errors)
    { errors: errors }
  end

  # Calculates the progress between x, witn min as 0 and max as 1.
  #
  # @param x [Integer] The number between min and max that we want
  #   the progress for.
  # @param min [Integer] The minimum point, that acts as 0 in the scale.
  #   Should be smaller than x.
  # @param max [Integer] The biggest points, that acts as 1 in the scale.
  #   Should be larger than x and min.
  #
  # @private
  #
  # @return [Float] The progress as a float.
  #
  def calculate_progress(x, min, max)
    ((x - min) / (max - min).to_f).round(1)
  end
end
