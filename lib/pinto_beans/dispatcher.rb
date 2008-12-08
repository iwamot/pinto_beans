module PintoBeans
  class Dispatcher
    def initialize(application, response)
      @application = application
      @response = response
    end

    def dispatch(request, route)
      @response.title = @application.name
      if @application.maintenance?
        @response.status_code = 503
        @response.content_language = 'en'
        @response.add_paragraph('503 Service Unavailable')
      elsif route.nil?
        @response.status_code = 404
        @response.content_language = 'en'
        @response.add_paragraph('404 Not Found')
      else
        if request.uri == 'http://pinto.jp/'
          @response.status_code = 300
          @response.content_language = 'en'
          @response.add_alternative_link(:href => 'http://en.pinto.jp/',
                                         :hreflang => 'en',
                                         :title => 'Pinto(en)')
          @response.add_alternative_link(:href => 'http://ja.pinto.jp/',
                                         :hreflang => 'ja',
                                         :title => 'Pinto(ja)')
        elsif request.uri == 'http://ja.pinto.jp/'
          @response.status_code = 200
          @response.content_language = 'ja'
          @response.content_location = 'http://pinto.jp/'
          @response.add_alternative_link(:href => 'http://en.pinto.jp/',
                                         :hreflang => 'en',
                                         :title => 'Pinto(en)')
        elsif request.uri == 'http://en.pinto.jp/'
          @response.status_code = 200
          @response.content_language = 'en'
          @response.content_location = 'http://pinto.jp/'
          @response.add_alternative_link(:href => 'http://ja.pinto.jp/',
                                         :hreflang => 'ja',
                                         :title => 'Pinto(ja)')
        else
          @response.status_code = 404
          @response.content_language = 'en'
          @response.add_paragraph('404 Not Found')
        end
      end

      @response
    end
  end
end
