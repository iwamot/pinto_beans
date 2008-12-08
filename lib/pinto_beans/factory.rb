require 'rubygems'
require 'rack'

require 'pinto_beans/application'
require 'pinto_beans/dispatcher'
require 'pinto_beans/front_controller'
require 'pinto_beans/helper/string'
require 'pinto_beans/helper/strings'
require 'pinto_beans/request'
require 'pinto_beans/response'
require 'pinto_beans/route'
require 'pinto_beans/router'
require 'pinto_beans/web_handler/rack'
require 'pinto_beans/web_interfacer/request/rack'
require 'pinto_beans/web_interfacer/response/rack'
require 'pinto_beans/web_server/mongrel'
require 'pinto_beans/wrapper/rack_request'

module PintoBeans
  class Factory
    def initialize(app_name, app_dir, port, mode)
      @app_name = app_name
      @app_dir = app_dir
      @port = port
      @mode = mode
    end

    def web_server
      PintoBeans::WebServer::Mongrel.new(
        Rack::ShowExceptions.new(
          Rack::Lint.new(
            PintoBeans::WebHandler::Rack.new(self)
          )
        ), @port
      )
    end

    def request_interfacer
      PintoBeans::WebInterfacer::Request::Rack.new(
        PintoBeans::Request.new,
        PintoBeans::Wrapper::RackRequest.new,
        PintoBeans::Helper::String.new(
          PintoBeans::Helper::Strings.new
        )
      )
    end

    def front_controller
      PintoBeans::FrontController.new(
        PintoBeans::Router.new(PintoBeans::Route.new),
        PintoBeans::Dispatcher.new(
          PintoBeans::Application.new(@app_name, @app_dir, @mode),
          PintoBeans::Response.new
        )
      )
    end

    def response_interfacer
      PintoBeans::WebInterfacer::Response::Rack.new
    end
  end
end
