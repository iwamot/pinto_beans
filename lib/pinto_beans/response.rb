module PintoBeans
  class Response
    attr_accessor :status_code
    attr_accessor :title
    attr_accessor :content_language
    attr_accessor :content_location

    def initialize
      @links = []
      @paragraphs = []
    end

    def add_alternative_link(attributes)
      attributes[:rel] = 'alternative'
      @links.push(attributes)
    end

    def add_paragraph(text)
      @paragraphs.push(text)
    end

    def content
      content = '<?xml version="1.0" encoding="UTF-8"?>'
      content += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
      content += '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="' + @content_language + '">'
      content += '<head>'
      content += '<title>' + @title + '</title>'
      content += '</head>'
      content += '<body>'
      content += '<h1>' + @title + '</h1>'
      if @links.length > 0
        content += '<ul>'
        @links.each do |link|
          content += '<li><a rel="' + link[:rel]  + '" href="' + link[:href] + '" hreflang="' + link[:hreflang]  +'">' + link[:title]  + '</a></li>'
        end
        content += '</ul>'
      end
      @paragraphs.each do |text|
        content += '<p>' + text + '</p>'
      end
      content += '</body>'
      content += '</html>'
    end

    def has_content_location?
      !@content_location.nil?
    end
  end
end
