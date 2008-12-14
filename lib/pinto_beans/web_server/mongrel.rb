require 'rubygems'
require 'rack'

module PintoBeans
  module WebServer
    class Mongrel
      def initialize(web_handler, port)
        @web_handler = web_handler
        @port = port
      end

      def run
        ::Rack::Handler::Mongrel.run(@web_handler, :Port => @port)
      end
    end
  end
end
