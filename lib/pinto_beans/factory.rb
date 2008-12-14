require 'rubygems'
require 'optparse'
require 'rack'

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
require 'pinto_beans/wrapper/daemons'
require 'pinto_beans/wrapper/file'
require 'pinto_beans/wrapper/file_test'
require 'pinto_beans/wrapper/rack_request'

module PintoBeans
  class Factory
    def opt_parser
      OptionParser.new
    end

    def daemons
      PintoBeans::Wrapper::Daemons.new
    end

    def file
      PintoBeans::Wrapper::File.new
    end

    def filetest
      PintoBeans::Wrapper::FileTest.new
    end

    def web_server(port, app_dir)
      @app_dir = app_dir

      PintoBeans::WebServer::Mongrel.new(
        Rack::CommonLogger.new(
          Rack::ShowExceptions.new(
            Rack::Lint.new(
              Rack::Reloader.new(
                PintoBeans::WebHandler::Rack.new(self), 5
              )
            )
          )
        ), port
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
          PintoBeans::Response.new
        )
      )
    end

    def response_interfacer
      PintoBeans::WebInterfacer::Response::Rack.new
    end
  end
end
