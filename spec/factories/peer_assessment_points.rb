FactoryGirl.define do
  factory :peer_assessment_point do
    points { [10, 5, 20, 50].sample }
    date { DateTime.now }
    project { create :project }
    peer_assessment { create :peer_assessment }
    student { create :student }
    reason_id { [1,2,3].sample }
  end
end
