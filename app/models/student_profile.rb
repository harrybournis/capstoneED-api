class StudentProfile < ApplicationRecord
  belongs_to :student
  validates_presence_of :total_xp, :level
end
