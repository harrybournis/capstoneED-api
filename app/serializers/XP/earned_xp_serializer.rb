class XP::EarnedXpSerializer < ActiveModel::Serializer
  attributes :xp_earned, :total_xp, :xp_to_next_level, :level

  def xp_earned
    object.xp
  end

  def total_xp
    object.student.total_xp
  end

  def xp_to_next_level
    object.student.calculate_xp_to_next_level
  end

  def level
    object.student.level
  end

  type 'xp'
end
