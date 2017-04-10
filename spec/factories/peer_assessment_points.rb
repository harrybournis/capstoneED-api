FactoryGirl.define do
  factory :peer_assessment_point do
    points { [10, 5, 20, 50].sample }
    date { DateTime.now }
    project { create :project }
    peer_assessment { create :peer_assessment }
    student { create :student }
    reason do |r|
      if Reason.all.any?
        Reason.first
      else
        create :reason
      end
    end
  end
end
