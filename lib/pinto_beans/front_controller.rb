# Controller

module PintoBeans
  class FrontController
    def initialize(request, route)
      @request = request
      @route = route
    end

    def run
      begin
        return maintenance_controller.run if maintenance?
        return not_found_controller.run if not_found?
        controll
      rescue
        internal_server_error_controller.run
      end
    end

    def init_controller(name)
      Class.get("%s::%sController" % [
        PintoBeans::Config.new.app_name, name.camelize
      ]).new(@request, @route.params, self)
    end

    private

    def maintenance?
      PintoBeans::Config.new.maintenance?
    end

    def not_found?
      @route.controller_name == 'not_found'
    end

    def controll
      controller = init_controller(@route.controller_name)
      return controller.unauthorized        if controller.unauthorized?
      return controller.not_found           if controller.not_found?
      return controller.method_not_allowed  if controller.method_not_allowed?
      return controller.conflict            if controller.conflict?
      return controller.precondition_failed if controller.precondition_failed?
      return controller.multiple_choices    if controller.multiple_choices?
      return controller.not_modified        if controller.not_modified?
      controller.run
    end

    def maintenance_controller
      init_controller('maintenance')
    end

    def not_found_controller
      init_controller('not_found')
    end

    def internal_server_error_controller
      init_controller('internal_server_error')
    end
  end
end
