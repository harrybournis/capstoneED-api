FactoryGirl.define do
  factory :revoked_token do |f|
  	f.association  :user, factory: :user
  	f.jti "i7sqeESEDJHUSBZd4HJN42o1"
  	f.exp DateTime.now
  end
end
