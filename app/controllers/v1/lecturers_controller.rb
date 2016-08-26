class LecturersController < ApplicationController

	skip_before_action :authenticate_user_jwt, only: [:create]

	before_action :allow_if_self, only: [:update, :destroy]


	# POST '/register'
	# Register a new user using email and password as authentication
	def create
		if !lecturer_params['email'] || !lecturer_params['password'] || !lecturer_params['password_confirmation']
			render json: '', status: :bad_request
			return
		end

		@lecturer = User.new(lecturer_params).process_new_record

		if @lecturer.save
			render json: '', status: :created
		else
			render json: format_errors(@lecturer.errors), status: :unprocessable_entity
		end
	end


	# PUT '/users/:id'
	# Requires current_password if password is to be updated
	def update
		update_method = lecturer_params[:current_password] ? 'update_with_password' : 'update_without_password'

		if @lecturer.method(update_method).call(lecturer_params)
			render json: @lecturer, status: :ok
		else
			render json: format_errors(@lecturer.errors), status: :unprocessable_entity
		end
	end


	# DELETE destroy
	# Requires current_password
	def destroy
		if @lecturer.destroy_with_password(lecturer_params[:current_password])
			render json: '', status: :no_content
		else
			render json: format_errors(@lecturer.errors), status: :unprocessable_entity
		end
	end


private

	def allow_if_self
		if current_user.id.to_s == lecturer_params[:id]
			@lecturer = current_user.load
		else
			render json: format_errors({ user: ["Lecturer with id #{lecturer_params[:id]} is not authorized to access this resourse." ]}),
				status: :forbidden
		end
	end

	def lecturer_params
		params.permit(:id, :first_name, :last_name, :email, :password, :password_confirmation,
			:current_password)
	end

end
