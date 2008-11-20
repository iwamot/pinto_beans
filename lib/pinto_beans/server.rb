require 'rubygems'
require 'rack'
require 'pinto_beans/rack_handler'

module PintoBeans
  class Server
    def start
      begin
        Rack::Handler::Mongrel.run \
          Rack::ShowExceptions.new(Rack::Lint.new(PintoBeans::RackHandler.new)),
          :Port => 80
      rescue Interrupt
        puts 'stopped.'
      end
    end
  end
end

