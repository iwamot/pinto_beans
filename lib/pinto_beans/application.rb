module PintoBeans
  class Application
    def initialize(name, dir, mode)
      @name = name
      @dir = dir
      @mode = mode
    end

    def name
      @name
    end

    def dir
      @dir
    end

    def maintenance?
      @mode == 'maintenance'
    end
  end
end
