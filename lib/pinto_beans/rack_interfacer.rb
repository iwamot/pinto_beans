# Interfacer

module PintoBeans
  class RackInterfacer
    def self.env_to_request(env)
      rack_request = Rack::Request.new(env)
      self.wrap_request(rack_request)
    end

    def self.wrap_request(rack_request)
      request = PintoBeans::HttpRequest.new
      request.uri           = rack_request.url
      request.method        = rack_request.request_method
      request.headers       = self.extract_headers(rack_request.env)
      request.cookies       = rack_request.cookies
      request.query_strings = rack_request.GET
      request.form_data     = rack_request.POST
      request
    end

    def self.response_to_array(response)
      [
        response.status_code,
        response.headers,
        response.body
      ]
    end

    def self.extract_headers(env)
      env.reject {|key, value| key.match(/^rack\..*$/)}
    end
  end
end
