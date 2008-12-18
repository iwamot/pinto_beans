require 'rubygems'
require 'rack'

require 'pinto_beans/handler/rack'
require 'pinto_beans/server/mongrel'

module PintoBeans
  module Factory
    class Server
      def initialize(rack_factory)
        @rack_factory = rack_factory
      end

      def create(app_dir)
        PintoBeans::Server::Mongrel.new(
          ::Rack::CommonLogger.new(
            ::Rack::ShowExceptions.new(
              ::Rack::Lint.new(
                ::Rack::Reloader.new(
                  PintoBeans::Handler::Rack.new(@rack_factory, app_dir),
                  5
                )
              )
            )
          )
        )
      end
    end
  end
end
