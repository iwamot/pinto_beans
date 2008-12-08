module PintoBeans
  module WebHandler
    class Rack
      def initialize(factory)
        @factory = factory
      end

      def call(env)
        pinto_request = @factory.request_interfacer.convert(env)
        pinto_response = @factory.front_controller.run(pinto_request)
        @factory.response_interfacer.convert(pinto_response)
      end
    end
  end
end
