class Class
  def self.get(class_name)
    class_name.split('::').inject(Object) do |parent, child|
       parent.const_get(child)
    end
  end
end
