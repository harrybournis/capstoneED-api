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
			Lecturers build forms from questions. Questions can either be chosen from a predefined
			set of questions, or a Lecturer can create their own custom question.
	  EOS
	end

	api :GET, '/predefined_questions', "Get all the predefined questions"
  meta :authentication? => true
  meta :lecturers_only => true
  error code: 401, desc: 'Authentication failed'
 	error code: 403, desc: 'Current User is not a Lecturer.'
  description <<-EOS
  	Get all predefined questions. Must be a Lecturer.
  EOS
  def index_predefined_questions
  end

  api :GET, '/custom_questions', "Current User's custom questions"
  meta :authentication? => true
  meta :lecturers_only => true
  error code: 401, desc: 'Authentication failed'
 	error code: 403, desc: 'Current User is not a Lecturer.'
	error code: 403, desc: 'Current User is not associated with this resource'
  description <<-EOS
  	Get the current user's custom questions
  EOS
  def index_custom_questions
  end

	api :GET, 'predefined_questions/:id', 'Show a predefined question'
  meta :authentication? => true
  meta :lecturers_only => true
  param :id, Integer, 'The id of the Predefined Question to be returned', required: true
  error code: 401, desc: 'Authentication failed'
 	error code: 403, desc: 'Current User is not a Lecturer.'
	error code: 403, desc: 'This User is not the owner of this resource'
	description <<-EOS
		Returns the Predefined Question specified by the id in the params. The User must be logged in, a Lecturer,
		and the Predefined Question must belong to them.
	EOS
	def show_custom_question
	end

	api :GET, 'custom_questions/:id', 'Show a custom question'
  meta :authentication? => true
  meta :lecturers_only => true
  param :id, Integer, 'The id of the Custom Question to be returned', required: true
  error code: 401, desc: 'Authentication failed'
 	error code: 403, desc: 'Current User is not a Lecturer.'
	error code: 403, desc: 'This User is not the owner of this resource'
	description <<-EOS
		Returns the Custom Question specified by the id in the params. The User must be logged in, a Lecturer,
		and the Custom Question must belong to them.
	EOS
	def show_custom_question
	end

	api :POST, '/custom_questions', 'Create a new Custom Question resource'
	meta :authentication? => true
  meta :lecturers_only => true
	param :text, 		String, "The description of the question for the students", 		required: true
	param :category, 	String, "The type of question. Can be Question or Comment",	required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 422, desc: "Text or Category are missing from the params"
	description <<-EOS
		Create a new Custom Question.
	EOS
	def create
	end

	api :PATCH, '/custom_questions/:id', 'Update Custom Question'
	meta :authentication? => true
  meta :lecturers_only => true
	param :id, String, 'The id of the Custom Question', required: true
	param :text, 		String, "The description of the question for the students"
	param :category, 	String, "The type of question. Can be Question or Comment"
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'This User is not the owner of this resource'
	error code: 422, desc: "University or name are missing from the params"
	description <<-EOS
		Update a Custom Question resource.
	EOS
	def update
	end

	api :DELETE, '/custom_questions/:id', 'Delete Department'
	meta :authentication? => true
  meta :lecturers_only => true
	param :id, String, 'The id of the department', required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a lecturer'
	error code: 403, desc: 'This User is not the owner of this resource'
	error code: 422, desc: "University or name are missing from the params"
	description <<-EOS
		Delete Custom Question resource
	EOS
	def destroy
	end
end
