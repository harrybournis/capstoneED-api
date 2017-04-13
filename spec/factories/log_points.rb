FactoryGirl.define do
  factory :log_point do
  	points { [10, 5, 20, 50].sample }
  	date { DateTime.now }
  	log_id 1
    project { create :project }
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