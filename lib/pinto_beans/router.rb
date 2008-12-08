module PintoBeans
  class Router
    def initialize(route)
      @route = route
    end

    def detect(request)
@route.controller = 'test'
      @route
    end
  end
end
