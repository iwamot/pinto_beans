module PintoBeans
  module Helper
    class Strings
      def capitalize(strings)
        strings.map do |string|
          string.capitalize
        end
      end

      def join(strings, delimiter)
        strings.join(delimiter)
      end
    end
  end
end
