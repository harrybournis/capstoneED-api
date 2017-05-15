# Module for authenticating using JWTs
module JWTAuth
  # The superclass for the CurrentUserStudent and CurrentUserLecturer
  # classes. Used in order to avoid loading the object from the
  # database unless needed.
  class CurrentUser
    attr_reader :id, :type, :current_device

    def initialize(user_id, type, device)
      @id             = user_id
      @type           = type
      @current_device = device
    end

    # Loads the user object from the database.
    #
    # @return [User] The user object
    def load
      @user ||= User.find(@id)
    end

    # Sign the current_user out
    #
    # @return [Boolean] True if signed out. False if error.
    def sign_out
      if active_token = ActiveToken.find_by_device(current_device)
        active_token.destroy
      end
    end

    private

    def method_missing(method_sym, *arguments, &block)
      if load.respond_to? method_sym
        load.send(method_sym, *arguments, &block)
      else
        super
      end
    end

    def respond_to_missing?(_, _)
      true
    end
  end
end
