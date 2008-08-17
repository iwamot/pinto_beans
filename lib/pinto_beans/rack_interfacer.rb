# Interfacer

module PintoBeans
  class RackInterfacer
    def call(env)
      request = transform_request(env)
      response = PintoBeans::Router.new.route(request)
      transform_response(response)
    end

    private

    def transform_request(env)
      rack_request = Rack::Request.new(env)
      request = PintoBeans::HttpRequest.new
      request.uri           = rack_request.url
      request.method        = rack_request.request_method
      request.headers       = env.reject do |key, value|
                                key.match(/^rack\..*$/)
                              end
      request.cookies       = rack_request.cookies
      request.query_strings = rack_request.GET
      request.form_data     = rack_request.POST
      request
    end

    def transform_response(response)
      [
        response.status_code,
        response.headers,
        response.body
      ]
    end
  end
end
