class V1::StudentsController < ApplicationController

	skip_before_action :authenticate_user_jwt, only: [:create]

	before_action :allow_if_self, only: [:update, :destroy]
	before_action :allow_if_student, only: [:update, :destroy]


	# POST '/students'
	# Register a new user using email and password as authentication
	# def create
	# 	@student = Student.new(student_params).process_new_record

	# 	if @student.save
	# 		render json: @student, status: :created
	# 	else
	# 		render json: format_errors(@student.errors), status: :unprocessable_entity
	# 	end
	# end

	# PUT '/students/:id'
	# Requires current_password if password is to be updated
	# def update
	# 	update_method = student_params[:current_password] ? 'update_with_password' : 'update_without_password'

	# 	if @student.method(update_method).call(student_params)
	# 		render json: @student, status: :ok
	# 	else
	# 		render json: format_errors(@student.errors), status: :unprocessable_entity
	# 	end
	# end

	# DELETE /students/:id
	# Requires current_password
	# def destroy
	# 	if @student.destroy_with_password(student_params[:current_password])
	# 		render json: '', status: :no_content
	# 	else
	# 		render json: format_errors(@student.errors), status: :unprocessable_entity
	# 	end
	# end


	private

		def allow_if_self
			if current_user.id.to_s == student_params[:id]
				@student = current_user.load
			else
				render json: format_errors({ user: ["User with id #{student_params[:id]} is not authorized to access this resourse." ]}),
					status: :forbidden
			end
		end

		def student_params
			params.permit(:id, :first_name, :last_name, :email, :password, :password_confirmation,
				:current_password)
		end

end
