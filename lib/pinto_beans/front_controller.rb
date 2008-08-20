# Controller

module PintoBeans
  class FrontController
    def initialize(request, route)
      @request = request
      @route = route
    end

    def run
#      begin
        return service_unavailable if service_unavailable?
        return not_found           if not_found?
        controll
#      rescue
#        internal_server_error
#      end
    end

    private

    def controll
      controller = new_controller(@route.controller_name)
      if not_found?(controller)
        not_found(controller)
      elsif method_not_allowed?(controller)
        method_not_allowed(controller)
      elsif unauthorized?(controller)
        unauthorized(controller)
      elsif multiple_choices?(controller)
        multiple_choices(controller)
      elsif not_modified?(controller)
        not_modified(controller)
      elsif precondition_failed?(controller)
        precondition_failed(controller)
      elsif conflict?(controller)
        conflict(controller)
      elsif options?
        options(controller)
      elsif get? || head?
        controller.get_action(@request, @route, response)
      elsif post?
        controller.post_action(@request, @route, response)
      elsif put?
        controller.put_action(@request, @route, response)
      elsif delete?
        controller.delete_action(@request, @route, response)
      end
    end

    def service_unavailable?
      PintoBeans::Config.new.maintenance?
    end

    def not_found?(controller = nil)
      return @route.controller_name == 'not_found' if controller.nil?
      return false unless controller.respond_to?(:not_found?)
      controller.not_found?(@request, @route)
    end

    def method_not_allowed?(controller)
      return !controller.respond_to?(:get_action)    if get? || head?
      return !controller.respond_to?(:post_action)   if post?
      return !controller.respond_to?(:put_action)    if put?
      return !controller.respond_to?(:delete_action) if delete?
      !options?
    end

    def unauthorized?(controller)
      return false unless controller.respond_to?(:unauthorized?)
      controller.unauthorized?(@request, @route)
    end

    def multiple_choices?(controller)
      return false unless get?
      return false unless @route.params['locale_code'] == ''
      controller.instance_variable_get('@support_multiple_choices')
    end

    def not_modified?(controller)
      return false unless (get? || head?)
      return false if (@request.if_modified_since.nil? &&
                       @request.if_none_match.nil?)
      return false unless controller.respond_to?(:last_modified?)

      last_modified = Time.http_date(controller.last_modified)
      unless @request.if_modified_since.nil?
        return false if @request.if_modified_since != last_modified
      end
      unless @request.if_none_match.nil?
        return false if @request.if_none_match != etag(last_modified)
      end
      true
    end

    def precondition_failed?(controller)
      return false unless (get? || head?)
      return false if (@request.if_unmodified_since.nil? &&
                       @request.if_match.nil?)
      return false unless controller.respond_to?(:last_modified?)

      last_modified = Time.http_date(controller.last_modified)
      unless @request.if_unmodified_since.nil?
        return false if @request.if_unmodified_since == last_modified
      end
      unless @request.if_match.nil?
        return false if @request.if_match == etag(last_modifeid)
      end
      true
    end

    def conflict?(controller)
      return false unless (post? || put? || delete?)
      return false unless controller.respond_to?(:conflict?)
      controller.conflict?(@request, @route)
    end

    def new_controller(name)
      begin
        Class.get("%s::%sController" % [
          PintoBeans::Config.new.app_name, name.camelize
        ]).new
      rescue LoadError, NameError
        Class.get("PintoBeans::%sController" % name.camelize).new
      end
    end

    def run_controller(name, controller = nil)
      if !controller.nil? && controller.respond_to?(name)
        controller.send(name, response)
      else
        new_controller(name).run(@request, @route, response)
      end
    end

    def service_unavailable
      run_controller('service_unavailable')
    end

    def not_found(controller = nil)
      run_controller('not_found', controller)
    end

    def method_not_allowed(controller)
      run_controller('method_not_allowed', controller)
    end

    def unauthorized(controller)
      run_controller('unauthorized', controller)
    end

    def multiple_choices(controller)
      run_controller('multiple_choices', controller)
    end

    def not_modified(controller)
      run_controller('not_modified', controller)
    end

    def precondition_failed(controller)
      run_controller('precondition_failed', controller)
    end

    def conflict(controller)
      run_controller('conflict', controller)
    end

    def options
      run_controller('options')
    end

    def internal_server_error
      run_controller('internal_server_error')
    end

    def get?
      @request.get?
    end

    def head?
      @request.head?
    end

    def post?
      @request.post?
    end

    def put?
      @request.put?
    end

    def delete?
      @request.delete?
    end

    def options?
      @request.options?
    end

    def response
      PintoBeans::HttpResponse.new
    end
  end
end
