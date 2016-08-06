Rails.application.routes.draw do

	constraints subdomain: "api" do
		namespace :v1 do
			resources :users
		end
	end

	post 'auth/facebook', to: 'authentications#facebook'
	post 'omniauth/facebook', to: 'authentications#facebook'

end
