module PintoBeans
  class Request
    attr_accessor :environments
    attr_accessor :headers
    attr_accessor :uri

    def initialize
      @environments = {}
      @headers = {}
    end

    def add_header(key, value)
      @headers[key] = value
    end

    def add_environment(key, value)
      @environments[key] = value
    end
  end
end
