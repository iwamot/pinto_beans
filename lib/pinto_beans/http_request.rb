# Information Holder

module PintoBeans
  class HttpRequest
    attr_accessor :uri
    attr_accessor :method
    attr_accessor :headers
    attr_accessor :cookies
    attr_accessor :query_strings
    attr_accessor :form_data
  end
end
