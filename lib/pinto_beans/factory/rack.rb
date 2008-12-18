require 'pinto_beans/dispatcher'
require 'pinto_beans/front_controller'
require 'pinto_beans/helper/string'
require 'pinto_beans/helper/strings'
require 'pinto_beans/request'
require 'pinto_beans/response'
require 'pinto_beans/route'
require 'pinto_beans/router'
require 'pinto_beans/request_interfacer/rack'
require 'pinto_beans/response_interfacer/rack'
require 'pinto_beans/wrapper/rack_request'

module PintoBeans
  module Factory
    class Rack
      def create_request_interfacer
        PintoBeans::RequestInterfacer::Rack.new(
          PintoBeans::Request.new,
          PintoBeans::Wrapper::RackRequest.new,
          PintoBeans::Helper::String.new(
            PintoBeans::Helper::Strings.new
          )
        )
      end

      def create_front_controller
        PintoBeans::FrontController.new(
          PintoBeans::Router.new(
            PintoBeans::Route.new
          ),
          PintoBeans::Dispatcher.new(
            PintoBeans::Response.new
          )
        )
      end

      def create_response_interfacer
         PintoBeans::ResponseInterfacer::Rack.new
      end
    end
  end
end
