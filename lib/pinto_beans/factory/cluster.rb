require 'rubygems'
require 'optparse'
require 'pathname'

require 'pinto_beans/cluster'
require 'pinto_beans/factory/rack'
require 'pinto_beans/factory/server'
require 'pinto_beans/wrapper/daemons'
require 'pinto_beans/wrapper/pathname'

module PintoBeans
  module Factory
    class Cluster
      def create
        PintoBeans::Cluster.new(
          OptionParser.new,
          PintoBeans::Wrapper::Daemons.new,
          PintoBeans::Wrapper::Pathname.new,
          PintoBeans::Factory::Server.new(
            PintoBeans::Factory::Rack.new
          )
        )
      end
    end
  end
end
