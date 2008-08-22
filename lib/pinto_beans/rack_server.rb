# Coordinator

module PintoBeans
  class RackServer
    def call(env)
      request = PintoBeans::RackInterfacer.env_to_request(env)
      response = PintoBeans::Router.route(request)
      PintoBeans::RackInterfacer.response_to_array(response)
    end
  end
end
