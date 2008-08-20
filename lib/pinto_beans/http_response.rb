# Information Holder

module PintoBeans
  class HttpResponse
    attr_accessor :status_code
    attr_accessor :headers
    attr_accessor :body

    def initialize
      @headers = {'Content-Type' => ''}
    end
  end
end
