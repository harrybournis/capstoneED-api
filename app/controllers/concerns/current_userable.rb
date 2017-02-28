## Methods for the custom CurrentUser class and behavior
module CurrentUserable
  extend ActiveSupport::Concern

  # Returns a CurrentUser object, which responds to all the methods of a user.
  # Calling current_user.id, current_user.type or current_user.current_device
  # will return the values of the actual Student or Lecturer object without
  # making any database queries. By calling current_user.load, the actual
  # Student or Lecturer object is returned.
  def current_user
    @current
  end

  def user_signed_in?
    !@current.nil?
  end

  def allow_if_authenticated_by_email(extra_suggestion = nil)
    return if @current.provider == 'email'
    message = ["Provider is #{@current.provider}. Did not authenticate with email/password. #{extra_suggestion if extra_suggestion}"]
    render json: format_errors({ base: message }), status: :forbidden
    false
  end

  def allow_if_lecturer(extra_suggestion = nil)
    return if @current.type == 'Lecturer'
    message = ["You must be Lecturer to access this resource. #{extra_suggestion if extra_suggestion}"]
    render json: format_errors({ base: message }), status: :forbidden
    false
  end

  def allow_if_student(extra_suggestion = nil)
    return if @current.type == 'Student'
    message = ["You must be Student to access this resource. #{extra_suggestion if extra_suggestion}"]
    render json: format_errors({ base: message }), status: :forbidden
    false
  end

  # Renders error message with :forbidden status code
  def render_not_associated_with_current_user(resource)
    render json: format_errors({ base: ["This #{resource} is not associated with the current user"] }),
           status: :forbidden
  end
end
