class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :type, :provider, :avatar_url
  type :user
end
