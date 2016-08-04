Rails.application.routes.draw do

	namespace :api do
		namespace :v1 do
			mount_devise_token_auth_for 'User', at: 'auth'

			resources :users
		end
	end

	post 'auth/facebook', to: 'authentications#facebook'
	post 'omniauth/facebook', to: 'authentications#facebook'

end
