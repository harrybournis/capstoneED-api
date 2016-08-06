=begin #######
	Generates random resources using the Faker gem.

	Usage:
		DummyDataBuilder.<resourcename>(<optional: number of resources>)

	Returns:
		Object 	 if number of resources is 1
		[] Array if number of resources is > 1
=end   #######

class DummyDataBuilder

	def self.user(number=1, is_admin=false)
		results = []

		number.times do
			password = Faker::Internet.password(8)

			user = User.new(
				first_name: Faker::Name.first_name,
				last_name: Faker::Name.last_name,
				user_name: Faker::Internet.user_name,
				email: Faker::Internet.free_email,
				password: password,
				password_confirmation: password)

			if user.save
				Rails.logger.info "\n Randomly Created User: #{user.inspect} \n"

				results << user
			else
				Rails.logger.info user.errors
			end
		end

		to_return(results)
	end

private

	def self.to_return(results)
		if results.empty?
			return nil

		elsif results.size == 1
			return results.first

		else
			return results
		end
	end

end
