class Docs::V1::PeerAssessments < ApplicationController

	include Docs::Helpers::DocHelper
	DocHelper = Docs::Helpers::DocHelper

	resource_description do
	  short 'Peer Assesment is submitted by Students for Students'
	  name 'Peer Assessment Submit'
	  api_base_url '/v1'
	  api_version 'v1'
	  meta attributes: { pa_form_id: 'Integer', submitted_by_id: 'Integer', submitted_for_id: 'Integer', date_submitted: 'DateTime', answers: 'Array' }
	  description <<-EOS
			A Peer Assessment is submitted for a Student by a Student from the same Team for a PAForm in an Iteration
			of a Project. It contains the answers to the questions contained in the associated PAForm and the
			date and time it was submitted.
	  EOS
	end

	api :GET, 'peer_assessments', 'Get all peer assessments for a PAForm or for or by a Student.'
	meta :authentication? => true
	meta :lecturers_only => true
	meta :includes => true
	param :pa_form_id, Integer, 'The id of the PAForm that was completed.', required: true
	param :submitted_for_id, Integer, 'The id of the Student that the Peer Assessments were completed FOR'
	param :submitted_by_id, Integer, 'The id of the Student that the Peer Assessments were completed BY'
	error code: 401, desc: 'Authentication failed'
	error code: 400, desc: 'There was no pa_form_id in the params.'
	error code: 403, desc: 'Current User is not a Lecturer'
  error code: 403, desc: 'The pa_form_id does not belong to a PAForm associated with the current_user'
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"pa_form\": {\n    \"id\": 1,\n    \"iteration_id\": 1,\n    \"questions\": [\n      {\n        \"text\": \"What?\",\n        \"question_id\": 1\n      },\n      {\n        \"text\": \"Who?\",\n        \"question_id\": 2\n      },\n      {\n        \"text\": \"When?\",\n        \"question_id\": 3\n      },\n      {\n        \"text\": \"Where?\",\n        \"question_id\": 4\n      },\n      {\n        \"text\": \"Why?\",\n        \"question_id\": 5\n      }\n    ]\n  }\n}")
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"peer_assessments\": [\n    {\n      \"id\": 5,\n      \"pa_form_id\": 4,\n      \"submitted_by_id\": 1,\n      \"submitted_for_id\": 45,\n      \"date_submitted\": \"2016-11-05T16:22:17.333Z\",\n      \"answers\": [\n        {\n          \"answer\": \"Something\",\n          \"question_id\": 1\n        },\n        {\n          \"answer\": \"A guy\",\n          \"question_id\": 2\n        },\n        {\n          \"answer\": \"Yesterwhatever\",\n          \"question_id\": 3\n        },\n        {\n          \"answer\": \"You know where\",\n          \"question_id\": 4\n        },\n        {\n          \"answer\": \"Because\",\n          \"question_id\": 5\n        }\n      ]\n    },\n    {\n      \"id\": 4,\n      \"pa_form_id\": 4,\n      \"submitted_by_id\": 1,\n      \"submitted_for_id\": 44,\n      \"date_submitted\": \"2016-11-05T16:22:17.333Z\",\n      \"answers\": [\n        {\n          \"answer\": \"Something\",\n          \"question_id\": 1\n        },\n        {\n          \"answer\": \"A guy\",\n          \"question_id\": 2\n        },\n        {\n          \"answer\": \"Yesterwhatever\",\n          \"question_id\": 3\n        },\n        {\n          \"answer\": \"You know where\",\n          \"question_id\": 4\n        },\n        {\n          \"answer\": \"Because\",\n          \"question_id\": 5\n        }\n      ]\n    },\n    {\n      \"id\": 3,\n      \"pa_form_id\": 4,\n      \"submitted_by_id\": 1,\n      \"submitted_for_id\": 43,\n      \"date_submitted\": \"2016-11-05T16:22:17.333Z\",\n      \"answers\": [\n        {\n          \"answer\": \"Something\",\n          \"question_id\": 1\n        },\n        {\n          \"answer\": \"A guy\",\n          \"question_id\": 2\n        },\n        {\n          \"answer\": \"Yesterwhatever\",\n          \"question_id\": 3\n        },\n        {\n          \"answer\": \"You know where\",\n          \"question_id\": 4\n        },\n        {\n          \"answer\": \"Because\",\n          \"question_id\": 5\n        }\n      ]\n    },\n    {\n      \"id\": 2,\n      \"pa_form_id\": 4,\n      \"submitted_by_id\": 1,\n      \"submitted_for_id\": 42,\n      \"date_submitted\": \"2016-11-05T16:22:17.333Z\",\n      \"answers\": [\n        {\n          \"answer\": \"Something\",\n          \"question_id\": 1\n        },\n        {\n          \"answer\": \"A guy\",\n          \"question_id\": 2\n        },\n        {\n          \"answer\": \"Yesterwhatever\",\n          \"question_id\": 3\n        },\n        {\n          \"answer\": \"You know where\",\n          \"question_id\": 4\n        },\n        {\n          \"answer\": \"Because\",\n          \"question_id\": 5\n        }\n      ]\n    }\n  ]\n}", request = "{\"pa_form_id\"=>\"4\", \"submitted_by_id\"=>\"1\"")
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"peer_assessments\": [\n    {\n      \"id\": 6,\n      \"pa_form_id\": 4,\n      \"submitted_by_id\": 42,\n      \"submitted_for_id\": 1,\n      \"date_submitted\": \"2016-11-05T16:22:17.333Z\",\n      \"answers\": [\n        {\n          \"answer\": \"Something\",\n          \"question_id\": 1\n        },\n        {\n          \"answer\": \"A guy\",\n          \"question_id\": 2\n        },\n        {\n          \"answer\": \"Yesterwhatever\",\n          \"question_id\": 3\n        },\n        {\n          \"answer\": \"You know where\",\n          \"question_id\": 4\n        },\n        {\n          \"answer\": \"Because\",\n          \"question_id\": 5\n        }\n      ]\n    }\n  ]\n}", request = "{\"pa_form_id\"=>\"4\", \"submitted_for_id\"=>\"1\"")
	example DocHelper.format_example(status = 200, nil, body = "{\n  \"errors\": {\n    \"base\": [\n      \"There was no pa_form_id in the params. Try again with a pa_form_id in the params for all peer assessments for that PAForm, or with either a pa_form_id and a submitted_by_id or a pa_form_id and a submitted_for_id for specific Student's peer assessments.\"\n    ]\n  }\n}" )
	description <<-EOS
		A Lecturer can retrieve all Peer Assessments for a PAForm. If they include a Student's id as submitted_by_id in the
		params, they can get all Peer Assessments that were submitted BY that Student for the specific PAForm.
		If a Student's id is included as a submitted_for_id, then all the Peer Assessments submtted FOR that
		Student for the specific PAForm will be returned.
	EOS
	def get_peer_assessments
	end

	api :GET, 'peer_assessments/:id', 'Show an Peer Assessment'
  meta :authentication? => true
  meta :lecturers_only => true
	meta :includes => true
  param :id, Integer, 'The id of the Peer Assessment to be returned', required: true
  error code: 401, desc: 'Authentication failed'
  error code: 403, desc: 'Current User is not a Lecturer'
	error code: 403, desc: 'The Peer Assessment is not associated with the current user'
	description <<-EOS
		Returns a Peer Assessment. Must be associated with the current user.
	EOS
	def show_single_peer_assessment
	end

	api :POST, '/pa_forms', 'Create a new Peer Assessment resource'
	meta :authentication? => true
  meta :students_only => true
	param :pa_form_id, Integer, "The id of the PAForm. It must belong a PAForm of the current user.", required: true
	param :submitted_for_id, Integer, "The id of the Student that the PAForm is being submitted FOR. Must be a member of the Team of the current user.", required: true
	param :answers, Array, 'The Answers for the questions in the PAForm. Must be an Array of hashes containing the question_id and the answer. Format is: [{"question_id": 1, "answer": 3}, {"question_id": 1, "answer": "Interesting Unit"}]', required: true
	error code: 401, desc: 'Authentication failed'
	error code: 403, desc: 'Current User is not a Student'
	error code: 422, desc: "Params are missing or are invalid. See errors in the body of the response."
	example DocHelper.format_example(status = 201, nil, body = "{\n  \"peer_assessment\": {\n    \"id\": 1,\n    \"pa_form_id\": 1,\n    \"submitted_by_id\": 1,\n    \"submitted_for_id\": 3,\n    \"date_submitted\": \"2016-11-30T14:12:40.670Z\",\n    \"answers\": [\n      {\n        \"question_id\": \"3\",\n        \"answer\": \"1\"\n      },\n      {\n        \"question_id\": \"2\",\n        \"answer\": \"I enjoyed the presentations\"\n      }\n    ]\n  }\n}", request = "{\"answers\"=>[{\"answer\"=>\"1\", \"question_id\"=>\"3\"}, {\"answer\"=>\"I enjoyed the presentations\", \"question_id\"=>\"2\"}], \"pa_form_id\"=>\"1\", \"submitted_for_id\"=>\"3\}")
	description <<-EOS
		A Student submits a new Peer Assessment form for a Student in their Team. It is assumed that the
		Student submitting the form is the current user. The system will set the current Time as the
		submission date and time. There are a number of conditions that determine
		whether the submission is valid.
		The submission must happen before a PAForm's deadline.
		The submission must happen after a PAForm's start_date.
		The submission must be for a Project's PAForm that the current user is associated with.
		The Student that the assessment is FOR must be in the same Team as the current user.
		The Student that the assessment is FOR must not have been already assessmed the current user for this particular PAForm.
	EOS
	def submit_peer_assessment
	end

end
