class BaseParamsWrapper

	def initialize (params)
		@params = params
	end

	delegate :[], to: :params
	delegate :permitted, to: :params

private
	attr_reader :params
end
