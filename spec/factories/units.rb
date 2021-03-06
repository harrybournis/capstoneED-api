FactoryGirl.define do
  factory :unit do
    name          { "Unit #{rand(1000).to_s}" }
    code          { SecureRandom.base64(10) }
    semester      { ['Spring', 'Autumn'].sample }
    year          { ( Date.today - (1000*rand())).year }
    archived_at   nil
    association   :department, factory: :department
    association   :lecturer, factory: :lecturer
  end
end
