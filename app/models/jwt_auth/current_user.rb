module JWTAuth
  ## The superclass for the CurrentUserStudent and CurrentUserLecturer
  #  classes. Used in order to avoid loading the object from the
  #  database unless needed.
  class CurrentUser
    attr_reader :id, :type, :current_device

    def initialize(user_id, type, device)
      @id             = user_id
      @type           = type
      @current_device = device
    end

    def load
      @user ||= User.find(@id)
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
