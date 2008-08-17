# Service Provider

module PintoBeans
  class Translator
    def initialize(locale = 'en')
      @locale = locale
    end

    def _(message_id)
      GetText.set_output_charset('UTF-8')
      GetText.bindtextdomain(
        PintoBeans::Config.new.app_name, :path => 'locale'
      )
      GetText.set_locale(@locale)
      GetText._(message_id)
    end
  end
end
