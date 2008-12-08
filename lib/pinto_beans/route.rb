module PintoBeans
  class Route
    attr_accessor :controller
    attr_accessor :action

    def nil?
      @controller.nil?
    end
  end
end
