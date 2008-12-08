module PintoBeans
  module Helper
    class String
      def initialize(strings_helper)
        @strings_helper = strings_helper
      end

      def match_head(string, head)
        string.slice(0, head.length) == head
      end

      def butt(string, head)
        return string unless match_head(string, head)
        string.slice(head.length, string.length - head.length)
      end

      def capitalize(string, delimiter)
        strings = string.split(delimiter)
        capitalized_strings = @strings_helper.capitalize(strings)
        @strings_helper.join(capitalized_strings, delimiter)
      end

      def replace(string, pattern, replace)
        string.gsub(pattern, replace)
      end
    end
  end
end
