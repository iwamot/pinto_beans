# Information Holder

module PintoBeans
  class Config
    attr_reader :locales

    def initialize
      Class.get("#{self.app_name}::LocaleSetter").new.set(self)
    end

    def load(key)
      config = YAML.load_file('config/main.yml')
      raise ArgumentError.new('non-existent key was given') if config[key].nil?
      config[key]
    end

    def routes
      self.load('routes').map do |entry|
        route = PintoBeans::Route.new
        route.controller_name = entry[0]
        route.uri_template = entry[1]
        route
      end
    end

    def set_locale(code, name)
      @locales ||= []
      @locales.delete_if do |locale|
        locale.code == code
      end.push(PintoBeans::Locale.new(code, name))
    end

    def app_name
      self.load('app_name')
    end

    def maintenance?
      self.load('mode') == 'maintenance'
    end

    def _(value)
      value
    end
  end
end
