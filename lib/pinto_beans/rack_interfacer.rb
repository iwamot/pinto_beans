require 'pinto_beans/request'
require 'pinto_beans/response'

module PintoBeans
  class RackInterfacer
    def request(env)
      request = PintoBeans::Request.new
    end

    def response(response)
      rack_response = [
        200,
        {'Content-Type' => 'text/plain; charset=UTF-8'},
        'Hello World!'
      ] 
    end
  end
end
