module PintoBeans
  module WebInterfacer
    module Response
      class Rack
        def convert(pinto_response)
          headers = {}
          headers['Content-Type'] = 'application/xhtml+xml; charset=UTF-8'
          headers['Content-Language'] = pinto_response.content_language
          if pinto_response.has_content_location?
            headers['Content-Location'] = pinto_response.content_location
          end

          [
            pinto_response.status_code,
            headers,
            pinto_response.content
          ]
        end
      end
    end
  end
end
