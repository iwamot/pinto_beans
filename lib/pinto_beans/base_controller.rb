# Controller

module PintoBeans
  module BaseController
    def initialize(request, params, front_controller)
      @request = request
      @params = params
      @front_controller = front_controller
    end

    def unauthorized?
      false
    end

    def unauthorized
      forward('unauthorized')
    end

    def not_found?
      false
    end

    def not_found
      forward('not_found')
    end

    def method_not_allowed?
      false
    end

    def method_not_allowed
      forward('method_not_allowed')
    end

    def conflict?
      false
    end

    def conflict
      forward('conflict')
    end

    def precondition_failed?
      false
    end

    def precondition_failed
      forward('precondition_failed')
    end

    def multiple_choices?
      false
    end

    def multiple_choices
      forward('multiple_choices')
    end

    def not_modified?
      false
    end

    def not_modified
      forward('not_modified')
    end

    private

    def forward(name)
      @front_controller.init_controller(name).run
    end
  end
end
