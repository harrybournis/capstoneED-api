# Project mixin. Provides functionlaity with color for a project.
module Project::Colorable
  extend ActiveSupport::Concern

  # The value of color saturation that
  # the generated color will have.
  COLOR_SATURATION = 0.86

  # The valud of color lightness that the
  # generated color will have
  COLOR_LIGHTNESS = 0.48

  # Generates a new random color and stores it in the color
  # attribute of the project. It does not save the change
  def generate_random_color
    self.color = random_hex_color(COLOR_LIGHTNESS, COLOR_SATURATION)
    self
  end

  def random_hex_color(lightness, saturation)
    hue = rand * 360
    h = hue / 60.0
    c = (1 - (2 * lightness - 1).abs) * saturation
    x = c * (1 - ((h % 2) - 1).abs)
    m = lightness - c / 2

    r1, g1, b1 = case h.floor
                 when 0 then [c, x, 0]
                 when 1 then [x, c, 0]
                 when 2 then [0, c, x]
                 when 3 then [0, x, c]
                 when 4 then [x, 0, c]
                 when 5 then [c, 0, x]
                 end

    r = ((r1 + m) * 255).round
    g = ((g1 + m) * 255).round
    b = ((b1 + m) * 255).round

    format('#%02X%02X%02X', r, g, b)
  end
end
