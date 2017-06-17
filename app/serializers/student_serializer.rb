class StudentSerializer < UserSerializer
  attributes :xp

  def xp
    { total_xp: object.total_xp, level: object.level, xp_to_next_level: object.calculate_xp_to_next_level }
  end
end
