class TestResultFormatter
	# , { docs?: true, described_action: 'create_project', status: 200 }
  # This registers the notifications this formatter supports, and tells
  # us that this was written against the RSpec 3.x formatter API.
  RSpec::Core::Formatters.register self, :example_passed, :example_failed, :example_pending, :dump_summary

  @@SUCCESS_STATUSES = [200, 201, 204]

  def initialize(output)
    @output = output
    @export_results = []
  end

  def example_passed notification
  	@output << '.'
  	create_docs_example notification.example if notification.example.metadata[:docs?]
  end

  def example_pending notification
    @output << "*"
  end

  def example_failed notification
    @output << "F"
    @output << "\nFailed Example: #{notification.example.full_description}"
  end

  # run at the end of all tests
  def dump_summary notification
  	export_results unless @export_results.empty?

    @output << "\n\n Found #{@export_results.length} examples"
		@output << "\n\nFinished in #{RSpec::Core::Formatters::Helpers.format_duration(notification.duration)}."
  end

  private

  	# create the examples that will be exported at the end
  	def create_docs_example example
  		metadata = example.metadata

  		unless metadata[:controller_class] && metadata[:described_action] && metadata[:status] &&
  			!metadata[:lecturer?].nil? && metadata[:request_params] && metadata[:response_body] &&
         metadata[:response_headers]
  			error = "Error: Missing metadata from example: #{example.full_description}, ( #{example.file_path} )"
  			@output << "\n\n #{error} \n\n"
  			raise error
  		end

  		resource 	= metadata[:controller_class].to_s # e.g Project
  		action 		= metadata[:described_action]			# e.g. create_project
  		status		= metadata[:status]
  		lecturer  = metadata[:lecturer?]
  		request 	= metadata[:request_params]
  		response 	= metadata[:response_body]
      resp_headers = metadata[:response_headers]

			@export_results << ExportTestResult.new(resource, action, status, example.description,
			 !@@SUCCESS_STATUSES.include?(status), lecturer, request, response, resp_headers)
  	end

  	# write the results to files
  	def export_results
  		root_path = "./doc_examples"
  		FileUtils.rm_rf(root_path) if File.exists?(root_path) # clear directory

  		@export_results.each_with_index do |e, index|
  			directory_name = "#{root_path}/#{e.resource}/#{e.lecturer_or_student}/#{e.action}/#{e.success_or_error}"

  			FileUtils.makedirs(directory_name) unless File.exists?(directory_name) # create directory

				File.open("#{directory_name}/#{e.status}_#{index}.json", "a") do |f|
					f.write(e.to_json + "\n")
				end

  			@output << "\nResource: #{e.resource}, Action: #{e.action}, Status: #{e.status}, Description: #{e.description}, Error?: #{e.error?}, Lecturer?: #{e.lecturer?}"
  		end
  	end
end

# class stucture that holds each resutl
class ExportTestResult
	def initialize resource, action, status, description, error, lecturer, request_params, response_body, response_headers
		@resource = resource
		@action = action
		@status = status
		@description = description
		@error = error
		@lecturer = lecturer
		@request_params = request_params
    @response_body = response_body.include?("<html>") ? CGI::escapeHTML(response_body) : response_body
		@response_headers = response_headers
	end

	attr_reader :resource, :action, :status, :description, :error, :lecturer, :request_params, :response_body,
     :response_headers

	def error?
		@error
	end

	def lecturer?
		@lecturer
	end

	def description_parameterized
		@description.parameterize[0..15]
	end

	# used to create the 'suceess' or 'error' directory
	def success_or_error
		@error ?  "error" : "success"
	end

	def lecturer_or_student
		@lecturer ? "Lecturer" : "Student"
	end
end
