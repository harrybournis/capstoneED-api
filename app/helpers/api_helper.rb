module ApiHelper
  def format_errors(errors)
    { errors: errors }
  end

  def calculate_progress(x, min, max)
    ((x - min) / (max - min).to_f).round(1)
  end
end
