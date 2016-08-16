class UserParamsWrapper < BaseParamsWrapper
	def email ; 				params['email'] 				end
	def password ; 				params['password'] 				end
	def password_confirmation ; params['password_confirmation'] end
	def first_name ; 			params['first_name']			end
	def last_name ; 			params['last_name']				end
end
