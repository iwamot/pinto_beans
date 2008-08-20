# Service Provider

module PintoBeans
  class UriExtractProcessor
    def match(name)
      begin
        validator(name).matcher
      rescue => e
        '.*'
      end
    end

    def restore(name, value)
      URI.unescape(
        begin
          validator(name).restore_proc.call(value)
        rescue => e
          value
        end
      )
    end

    private

    def validator(name)
      config = PintoBeans::Config.new
      validator = Class.get("%s::%sValidator" % [
        config.app_name, name.camelize
      ]).new
      validator.config = config if validator.respond_to?(:config=)
      validator
    end
  end
end
