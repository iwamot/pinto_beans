require 'pinto_beans/rack_interfacer'
require 'pinto_beans/router'
require 'pinto_beans/dispatcher'

module PintoBeans
  class RackHandler
    def call(env)
      rack_interfacer = PintoBeans::RackInterfacer.new
      request = rack_interfacer.request(env)
      route = PintoBeans::Router.new.detect(request)
      response = PintoBeans::Dispatcher.new.dispatch(request, route)
      rack_interfacer.response(response)
    end
  end
end
