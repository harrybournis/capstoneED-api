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

  def calculate_progress(x, min, max)
    ((x - min) / (max - min).to_f).round(1)
  end
end
