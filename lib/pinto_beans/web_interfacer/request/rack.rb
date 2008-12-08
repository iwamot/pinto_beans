module PintoBeans
  module WebInterfacer
    module Request
      class Rack
        def initialize(pinto_request, rack_request, string_helper)
          @pinto_request = pinto_request
          @rack_request = rack_request
          @string_helper = string_helper
        end

        def convert(original_request)
          original_request.each do |key, value|
            if @string_helper.match_head(key, 'HTTP_')
              key_butt = @string_helper.butt(key, 'HTTP_')
              capitalized_key_butt = @string_helper.capitalize(key_butt, '_')
              header_key = @string_helper.replace(capitalized_key_butt, '_', '-')
              @pinto_request.add_header(header_key, value)
            elsif !@string_helper.match_head(key, 'rack.')
              @pinto_request.add_environment(key, value)
            end
          end
          @pinto_request.uri = @rack_request.uri(original_request)
          @pinto_request
        end
      end
    end
  end
end
