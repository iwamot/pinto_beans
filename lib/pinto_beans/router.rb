# Coordinator

module PintoBeans
  class Router
    def route(request)
      route = detect_route(request)
      PintoBeans::FrontController.new(request, route).run
    end

    private

    def detect_route(request)
      route = PintoBeans::UriExtractor.new.extract(
        PintoBeans::Config.new.routes, request.uri
      )
      route.nil? ? default_route : route
    end

    def default_route
      route = PintoBeans::Route.new
      route.controller_name = 'not_found'
      route
    end
  end
end
