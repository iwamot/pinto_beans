module PintoBeans
  class FrontController
    def initialize(router, dispatcher)
      @router = router
      @dispatcher = dispatcher
    end

    def run(request)
      route = @router.detect(request)
      @dispatcher.dispatch(request, route)
    end
  end
end
