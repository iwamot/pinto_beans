# Information Holder

module PintoBeans
  class Locale
    attr_accessor :code
    attr_accessor :name

    def initialize(code, name)
      @code = code
      @name = name
    end
  end
end
