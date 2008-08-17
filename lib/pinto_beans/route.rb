# Information Holder

module PintoBeans
  class Route
    attr_accessor :controller_name
    attr_accessor :uri_template
    attr_accessor :params

    def initialize
      @uri_template = ''
      @params = {}
    end
  end
end
