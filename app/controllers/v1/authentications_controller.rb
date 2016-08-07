class V1::AuthenticationsController < ApplicationController

	# validates the JWT access-token
	def validate
		# validate token
		# if valid? -> 200 OK
		# else 		-> 401 Unauthorized
	end

	# creates a new JWT access-token using the refresh-token
	def refresh
	end

	def email
	end

	def facebook
		client = OAuth2::Client.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET'], site: 'https://graph.facebook.com/v2.7', token_url: "/oauth/access_token")

		client.auth_code.authorize_url(:redirect_uri => 'http://localhost:3000/')

		token = client.auth_code.get_token(params[:authentication][:code], redirect_uri: "http://localhost:3000/", parse: :query)
		facebook_response = token.get('/me', :params => { fields: 'id,first_name,last_name,email' })

		user_info = JSON.parse(facebook_response.body)

		user_info.delete("id")


		unless user_info.blank?

			member = Member.where(uid: user_info["email"]).first

			member = Member.from_omniauth(user_info) if member.blank?


			if member.blank?

				render json: :none, status: :unprocessable_entity

			else
				sign_in(:user, member, store: false, bypass: false)
				new_auth_header = member.create_new_auth_token(user_info["clientId"])
				response.headers.merge!(new_auth_header)

				render json: member, serializer: MemberSerializer, status: :ok
			end

		else
			render json: :none, status: :unprocessable_entity
		end
	end

	def google
	end
end
