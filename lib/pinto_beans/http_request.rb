# Information Holder

module PintoBeans
  class HttpRequest
    attr_accessor :uri
    attr_accessor :method
    attr_accessor :headers
    attr_accessor :cookies
    attr_accessor :query_strings
    attr_accessor :form_data

    def get?
      @method == 'GET'
    end

    def head?
      @method == 'HEAD'
    end

    def post?
      @method == 'POST'
    end

    def put?
      @method == 'PUT'
    end

    def delete?
      @method == 'DELETE'
    end

    def options?
      @method == 'OPTIONS'
    end

    def if_modified_since
      http_date('If-Modified-Since')
    end

    def if_none_match
      @header['If-None-Match']
    end

    def if_unmodified_since
      http_date('If-Unmodified-Since')
    end

    def if_match
      @header['If-Match']
    end

    private

    def http_date(header_name)
      begin
        Time.http_date(@headers[header_name])
      rescue
        nil
      end
    end
  end
end
