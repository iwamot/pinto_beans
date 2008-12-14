require 'rubygems'
require 'daemons'

module PintoBeans
  module Wrapper
    class Daemons
      def call(options, &block)
        ::Daemons.call(options, &block)
      end

      def run_proc(app_name, options, &block)
        ::Daemons.run_proc(app_name, options, &block)
      end
    end
  end
end
