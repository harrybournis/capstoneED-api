class V1::LecturersController < ApplicationController

	skip_before_action :authenticate_user_jwt, only: [:create]

	before_action :allow_if_self, only: [:update, :destroy]
	before_action :allow_if_lecturer, only: [:update, :destroy]


	# POST '/register'
	# Register a new user using email and password as authentication
	# def create
	# 	@lecturer = Lecturer.new(lecturer_params).process_new_record

	# 	if @lecturer.save
	# 		render json: @lecturer, status: :created
	# 	else
	# 		render json: format_errors(@lecturer.errors), status: :unprocessable_entity
	# 	end
	# end

	# PUT '/users/:id'
	# Requires current_password if password is to be updated
	# def update
	# 	update_method = lecturer_params[:current_password] ? 'update_with_password' : 'update_without_password'

	# 	if @lecturer.method(update_method).call(lecturer_params)
	# 		render json: @lecturer, status: :ok
	# 	else
	# 		render json: format_errors(@lecturer.errors), status: :unprocessable_entity
	# 	end
	# end

	# DELETE destroy
	# Requires current_password
	# def destroy
	# 	if @lecturer.destroy_with_password(lecturer_params[:current_password])
	# 		render json: '', status: :no_content
	# 	else
	# 		render json: format_errors(@lecturer.errors), status: :unprocessable_entity
	# 	end
	# end


	private

		def allow_if_self
			if current_user.id.to_s == lecturer_params[:id]
				@lecturer = current_user.load
			else
				render json: format_errors({ user: ["User with id #{lecturer_params[:id]} is not authorized to access this resourse." ]}),
					status: :forbidden
			end
		end

		def lecturer_params
			params.permit(:id, :email, :password, :password_confirmation, :current_password,
				:first_name, :last_name, :university, :position )
		end

end
