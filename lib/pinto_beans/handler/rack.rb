module PintoBeans
  module Handler
    class Rack
      def initialize(factory, app_dir)
        @factory = factory
        @app_dir = app_dir
      end

      def call(env)
        pinto_request = @factory.create_request_interfacer.convert(env)
        pinto_response = @factory.create_front_controller.run(pinto_request, @app_dir)
        @factory.create_response_interfacer.convert(pinto_response)
      end
    end
  end
end
