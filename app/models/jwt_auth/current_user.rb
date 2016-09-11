class JWTAuth::CurrentUser
	attr_reader :id, :type, :current_device

	def initialize (user_id, type, device)
		@id   					= user_id
		@type 					= type
		@current_device = device
	end

	def load
		@user ||= User.find(@id)
	end

private

	def method_missing (method_sym, *arguments, &block)
		load.send(method_sym, *arguments, &block)
	end
end
