module Project::Colorable
  extend ActiveSupport::Concern

  COLOR_SATURATION = 0.3
  COLOR_LIGHTNESS = 0.75

  # Generates a new random color and stores it in the color
  # attribute of the project. It does not save the change
  def generate_random_color
    gen = ColorGenerator.new saturation: COLOR_SATURATION,
                             lightness: COLOR_LIGHTNESS
    self.color = "##{gen.create_hex}"
    self
  end
end
