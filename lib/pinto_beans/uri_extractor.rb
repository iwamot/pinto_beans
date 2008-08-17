# Service Provider

module PintoBeans
  class UriExtractor
    def extract(routes, uri)
      parsed_uri = Addressable::URI.parse(uri)
      routes.each do |route|
        params = parsed_uri.extract_mapping(
          route.uri_template, PintoBeans::UriExtractProcessor.new
        )
        unless params.nil?
          route.params = params
          return route
        end
      end
      nil
    end
  end
end
