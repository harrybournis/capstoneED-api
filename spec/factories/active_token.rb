FactoryBot.define do
  factory :active_token do
    association  :user, factory: :user
    exp { DateTime.now }
    device { SecureRandom.base64(32) }
  end
end
