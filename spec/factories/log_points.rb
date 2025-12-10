FactoryBot.define do
  factory :log_point do
  	points { [10, 5, 20, 50].sample }
  	date { DateTime.now }
    project { create :project }
    student { create :student }
    reason_id { [1,2,3].sample }
  end
end
