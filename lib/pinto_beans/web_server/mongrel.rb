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
        begin
          ::Rack::Handler::Mongrel.run(@web_handler, :Port => @port)
        rescue Interrupt
          puts 'stopeed'
        end
      end
    end
  end
end
