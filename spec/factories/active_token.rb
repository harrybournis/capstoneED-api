FactoryBot.define do
  factory :active_token do |f|
  	f.association  :user, factory: :user
  	f.exp DateTime.now
  	f.device SecureRandom.base64(32)
  end
end
