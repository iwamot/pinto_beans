require 'pinto_beans/class'
require 'pinto_beans/string'

module PintoBeans
  def self.version
    return '0.0.1'
  end

  autoload :MethodNotAllowedController, 'pinto_beans/controllers/method_not_allowed'
  autoload :NotFoundController, 'pinto_beans/controllers/not_found'
  autoload :ServiceUnavailableController, 'pinto_beans/controllers/service_unavailable'
  autoload :UnauthorizedController, 'pinto_beans/controllers/unauthorized'

  autoload :Config, 'pinto_beans/config'
  autoload :BaseController, 'pinto_beans/base_controller'
  autoload :FrontController, 'pinto_beans/front_controller'
  autoload :HttpRequest, 'pinto_beans/http_request'
  autoload :HttpResponse, 'pinto_beans/http_response'
  autoload :Locale, 'pinto_beans/locale'
  autoload :RackInterfacer, 'pinto_beans/rack_interfacer'
  autoload :Route, 'pinto_beans/route'
  autoload :Router, 'pinto_beans/router'
  autoload :Translator, 'pinto_beans/translator'
  autoload :UriExtractor, 'pinto_beans/uri_extractor'
  autoload :UriExtractProcessor, 'pinto_beans/uri_extract_processor'
end

autoload :DBI, 'dbi'
autoload :Time, 'time'
autoload :URL, 'url'
autoload :YAML, 'yaml'

require 'rubygems'

gem 'addressable'
module Addressable
  autoload :URI, 'addressable/uri'
end

gem 'erubis'
autoload :Erubis, 'erubis'

gem 'gettext'
autoload :GetText, 'gettext'

gem 'ruby-openid'
autoload :OpenID, 'openid'
module OpenID
  module Store
    autoload :Filesystem, 'openid/store/filesystem'
  end
end

gem 'rack'
autoload :Rack, 'rack'
