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
      Class.get("#{PintoBeans::Config.new.app_name}::#{name.camelize}Validator").new
    end
  end
end
