module PintoBeans
  module Wrapper
    class File
      def dirname(filename)
        ::File.dirname(filename)
      end

      def expand_path(path)
        ::File.expand_path(path)
      end

      def join(*items)
        ::File.join(items)
      end
    end
  end
end
