# Controller

module PintoBeans
  class UnauthorizedController
    def run(request, route, response)
      response.status_code = 401
      response.headers = {'Content-Type' => 'text/plain; charset=UTF-8'}
      response.body = 'PintoBeans: 401 Unauthorized'
      response
    end
  end
end
