require 'pathname'

module PintoBeans
  module Wrapper
    class Pathname 
      def pwd
        ::Pathname.pwd
      end
    end
  end
end
