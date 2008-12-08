require 'rubygems'
require 'rack'

module PintoBeans
  module Wrapper
    class RackRequest
      def uri(env)
        request(env).url
      end

      def request(env)
        @request ||= Rack::Request.new(env)
        @request
      end
    end
  end
end
