class V1::DepartmentsController < ApplicationController

	before_action :allow_if_lecturer
	before_action :set_department, except: [:create, :index]


	# GET /departments
	# def index
	# 	@departments = Department.all
	# 	serialize_collection_params @departments, :ok
	# end

	# POST /departments
	def create
		@department = Department.new(department_params)

		if @department.save
			render json: @department, status: :created
		else
			render json: format_errors(@department.errors), status: :unprocessable_entity
		end
	end

	# PATCH /departments/:id
	def update
		if @department.update(department_params)
			render json: @department, status: :ok
		else
			render json: format_errors(@department.errors), status: :unprocessable_entity
		end
	end

	# DELETE /departments/:id
	def destroy
		if @department.destroy
			render json: '', status: :no_content
		else
			render json: format_errors(@user.errors), status: :unprocessable_entity
		end
	end


	private

		def set_department
			@department = Department.find(params[:id])
		end

		def department_params
			params.permit(:id, :university, :name)
		end
end
