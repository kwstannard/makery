module Makery
  # Builder builds the instance
  Builder = Struct.new(:attrs, :klass, :instantiation_method, :id) do
    attr_accessor :object
    def self.call(*args)
      new(*args).call
    end

    def call
      self.object = klass.send(instantiation_method)
      evaluate_delayed_attrs
      set_object_attributes
      object
    end

    def evaluate_delayed_attrs
      attrs.each { |k, v| attrs[k] = (v.respond_to?(:call) ? v.call(self) : v) }
    end

    def set_object_attributes
      attrs.each { |k, v| object.send("#{k}=", v) }
    end

    def [](attr)
      a = attrs[attr]
      a.respond_to?(:call) ? a.call(self) : a
    end
  end
end
