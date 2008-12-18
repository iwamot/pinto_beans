require 'rubygems'
require 'rack'

module PintoBeans
  module Server
    class Mongrel
      def initialize(handler)
        @handler = handler
      end

      def run(port)
        ::Rack::Handler::Mongrel.run(@handler, :Port => port)
      end
    end
  end
end
