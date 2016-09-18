class Docs::V1::Questions < ApplicationController

	include Docs::Helpers::DocHelper
	DocHelper = Docs::Helpers::DocHelper

	resource_description do
	  short 'Forms contain Questions.'
	  name 'Questions'
	  api_base_url '/v1'
	  api_version 'v1'
	  meta attributes: { category: 'String', text: 'String', lecturer_id: 'Integer' }
	  description <<-EOS
			Lecturers build forms from questions. If a lecturer has used a Question in a form, it will be
			available for them to choose in later forms.
	  EOS
	end

  api :GET, '/questions', "Current User's questions"
  meta :authentication? => true
  meta :lecturers_only => true
  error code: 401, desc: 'Authentication failed'
 	error code: 403, desc: 'Current User is not a Lecturer.'
	error code: 403, desc: 'Current User is not associated with this resource'
  description <<-EOS
  	Get the current user's questions
  EOS
  def index_questions
  end

	api :GET, 'custom_questions/:id', 'Show a question'
  meta :authentication? => true
  meta :lecturers_only => true
  param :id, Integer, 'The id of the Question to be returned', required: true
  error code: 401, desc: 'Authentication failed'
 	error code: 403, desc: 'Current User is not a Lecturer.'
	error code: 403, desc: 'This User is not the owner of this resource'
	description <<-EOS
		Returns the Question specified by the id in the params. The User must be logged in, a Lecturer,
		and the Question must belong to them.
	EOS
	def show_question
	end

	api :POST, '/questions', 'Create a new Question resource'
	meta :authentication? => true
  meta :lecturers_only => true
	param :text, 		String, "The description of the question for the students", 		required: true
	param :category, 	String, "The type of question. Can be Question or Comment",	required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 422, desc: "Text or Category are missing from the params"
	description <<-EOS
		Create a new Question.
	EOS
	def create_question
	end

	api :PATCH, '/questions/:id', 'Update Question'
	meta :authentication? => true
  meta :lecturers_only => true
	param :id, String, 'The id of the Question', required: true
	param :text, 		String, "The description of the question for the students"
	param :category, 	String, "The type of question. Can be Question or Comment"
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'This User is not the owner of this resource'
	description <<-EOS
		Update a Question resource.
	EOS
	def update_question
	end

	api :DELETE, '/custom_questions/:id', 'Delete Custom Question'
	meta :authentication? => true
  meta :lecturers_only => true
	param :id, String, 'The id of the department', required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'This User is not the owner of this resource'
	description <<-EOS
		Delete Question resource
	EOS
	def destroy_question
	end
end
