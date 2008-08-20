module PintoBeans
  class Router
    def route(request)
      response = PintoBeans::HttpResponse.new
      response.status_code = 200
      response.headers = {}
      response.body = request.uri
      response
    end
  end
end
